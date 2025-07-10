#include "databasehandler.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

DatabaseHandler::DatabaseHandler(QObject *parent) : QObject(parent)
{
}

bool DatabaseHandler::initDb()
{
    // Use a standard location for the database file
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(path);
    if (!dir.exists())
        dir.mkpath(".");

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(path + "/trips.db");

    if (!m_db.open()) {
        qWarning() << "Error: connection with database failed:" << m_db.lastError();
        return false;
    }

    qInfo() << "Database connection is open at:" << m_db.databaseName();

    // Check if the table already exists to avoid trying to create it again
    QStringList tables = m_db.tables();
    if (!tables.contains("trips", Qt::CaseInsensitive)) {
        qInfo() << "Trips table does not exist. Creating and populating.";
        return populateDb();
    } else {
        qInfo() << "Trips table already exists. Checking for 'vehicle' column.";
        QSqlQuery q(m_db);
        q.prepare("PRAGMA table_info(trips)");
        if (!q.exec()) {
            qWarning() << "Failed to query table info:" << q.lastError().text();
            return false;
        }

        bool vehicleColumnExists = false;
        while (q.next()) {
            if (q.value("name").toString() == "vehicle") {
                vehicleColumnExists = true;
                break;
            }
        }

        if (!vehicleColumnExists) {
            qInfo() << "'vehicle' column does not exist. Adding it.";
            QSqlQuery alterQuery(m_db);
            if (!alterQuery.exec("ALTER TABLE trips ADD COLUMN vehicle TEXT")) {
                 qWarning() << "ERROR: Failed to add 'vehicle' column:" << alterQuery.lastError().text();
                 return false;
            }
            qInfo() << "Added 'vehicle' column. Populating with default data.";
            // Populate the new column with some default data for existing rows
            QSqlQuery updateQuery(m_db);
            if (!updateQuery.exec("UPDATE trips SET vehicle = 'FATEC-ACV 1'")) {
                qWarning() << "ERROR: Failed to populate 'vehicle' column:" << updateQuery.lastError().text();
                return false;
            }
            qInfo() << "Populated 'vehicle' column for existing trips.";
        }
    }

    qInfo() << "Database schema is up to date.";
    return true;
}

QVariantList DatabaseHandler::getTrips(int page, int pageSize)
{
    QVariantList trips;
    QSqlQuery query;

    // The OFFSET is how many records to skip (which page we are on)
    // The LIMIT is the size of the page
    query.prepare("SELECT id, date, driver, vehicle, notes, favorite FROM trips ORDER BY date DESC LIMIT :limit OFFSET :offset");
    query.bindValue(":limit", pageSize);
    query.bindValue(":offset", page * pageSize);

    if (!query.exec()) {
        qWarning() << "ERROR: Failed to get trips:" << query.lastError().text();
        return trips;
    }

    while (query.next()) {
        QVariantMap trip;
        trip["id"] = query.value("id");
        trip["name"] = query.value("driver").toString();
        trip["startDate"] = query.value("date").toString();
        trip["vehicle"] = query.value("vehicle").toString();
        trip["notes"] = query.value("notes").toString();
        trip["favorite"] = query.value("favorite").toBool();
        trips.append(trip);
    }

    return trips;
}

QVariantMap DatabaseHandler::getTripDetails(int tripId)
{
    QVariantMap tripDetails;
    QSqlQuery query;

    query.prepare("SELECT * FROM trips WHERE id = :id");
    query.bindValue(":id", tripId);

    if (!query.exec()) {
        qWarning() << "ERROR: Failed to get trip details:" << query.lastError().text();
        return tripDetails;
    }

    if (query.next()) {
        // Extract date and time from the datetime string
        QString dateTimeString = query.value("date").toString();
        QDateTime dateTime = QDateTime::fromString(dateTimeString, "yyyy-MM-dd hh:mm");

        tripDetails["id"] = query.value("id");
        tripDetails["name"] = query.value("driver").toString();
        tripDetails["startDate"] = dateTime.toString("yyyy-MM-dd");
        tripDetails["endDate"] = dateTime.toString("yyyy-MM-dd"); // Assuming same day
        tripDetails["startTime"] = dateTime.toString("hh:mm");
        // Calculate end time based on duration
        int durationMinutes = query.value("duration").toInt();
        QDateTime endDateTime = dateTime.addSecs(durationMinutes * 60);
        tripDetails["endTime"] = endDateTime.toString("hh:mm");
        tripDetails["duration"] = durationMinutes;
        tripDetails["startOdometer"] = query.value("start_battery").toDouble();
        tripDetails["endOdometer"] = query.value("end_battery").toDouble();
        tripDetails["energyUsed"] = query.value("energy_used").toDouble();
        tripDetails["distance"] = query.value("distance_m").toDouble();
        tripDetails["averageSpeed"] = query.value("avg_speed").toDouble();
        tripDetails["vehicle"] = query.value("vehicle").toString();
        tripDetails["location"] = query.value("location").toString();
        tripDetails["notes"] = query.value("notes").toString();
        tripDetails["favorite"] = query.value("favorite").toBool();
    }

    return tripDetails;
}

bool DatabaseHandler::updateTripFavoriteStatus(int tripId, bool isFavorite)
{
    QSqlQuery query;
    query.prepare("UPDATE trips SET favorite = :favorite WHERE id = :id");
    query.bindValue(":favorite", isFavorite);
    query.bindValue(":id", tripId);

    if (!query.exec()) {
        qWarning() << "ERROR: Failed to update favorite status:" << query.lastError().text();
        return false;
    }

    qInfo() << "Trip" << tripId << "favorite status updated to" << isFavorite;
    return true;
}

bool DatabaseHandler::updateTripNotes(int tripId, const QString &notes)
{
    QSqlQuery query;
    query.prepare("UPDATE trips SET notes = :notes WHERE id = :id");
    query.bindValue(":notes", notes);
    query.bindValue(":id", tripId);

    if (!query.exec()) {
        qWarning() << "ERROR: Failed to update notes:" << query.lastError().text();
        return false;
    }

    qInfo() << "Trip" << tripId << "notes updated.";
    return true;
}

bool DatabaseHandler::populateDb()
{
    QSqlQuery query;
    if (!query.exec("CREATE TABLE trips ("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                    "date TEXT, "
                    "duration INTEGER, "
                    "driver TEXT, "
                    "location TEXT, "
                    "vehicle TEXT, " // Added vehicle column
                    "start_battery REAL, "
                    "end_battery REAL, "
                    "energy_used REAL, "
                    "distance_m REAL, "
                    "avg_speed REAL, "
                    "notes TEXT, "
                    "favorite INTEGER, "
                    "photo TEXT"
                    ");")) {
        qWarning() << "ERROR: " << query.lastError().text();
        return false;
    }

    qInfo() << "Trips table created.";

    // Use prepared statements to safely insert data
    query.prepare("INSERT INTO trips (date, duration, driver, location, vehicle, start_battery, end_battery, energy_used, distance_m, avg_speed, notes, favorite, photo) VALUES "
                  "(:date, :duration, :driver, :location, :vehicle, :start_battery, :end_battery, :energy_used, :distance_m, :avg_speed, :notes, :favorite, :photo)");

    // Sample Data
    QVariantMap trip1;
    trip1[":date"] = "2025-07-01 10:05"; trip1[":duration"] = 12; trip1[":driver"] = "Luis"; trip1[":location"] = "Oporto"; trip1[":vehicle"] = "FATEC-ACV 1";
    trip1[":start_battery"] = 95.0; trip1[":end_battery"] = 88.3; trip1[":energy_used"] = 2.1; trip1[":distance_m"] = 820;
    trip1[":avg_speed"] = 4.1; trip1[":notes"] = "Obstacle course trial"; trip1[":favorite"] = 0; trip1[":photo"] = "";

    QVariantMap trip2;
    trip2[":date"] = "2025-07-02 11:00"; trip2[":duration"] = 15; trip2[":driver"] = "Jorge"; trip2[":location"] = "Oporto"; trip2[":vehicle"] = "FATEC-ACV 1";
    trip2[":start_battery"] = 90.0; trip2[":end_battery"] = 83.1; trip2[":energy_used"] = 2.5; trip2[":distance_m"] = 1050;
    trip2[":avg_speed"] = 4.2; trip2[":notes"] = "Line following lap"; trip2[":favorite"] = 1; trip2[":photo"] = "";

    QVariantMap trip3;
    trip3[":date"] = "2025-07-03 09:40"; trip3[":duration"] = 10; trip3[":driver"] = "Rui"; trip3[":location"] = "Oporto"; trip3[":vehicle"] = "FATEC-ACV 1";
    trip3[":start_battery"] = 98.0; trip3[":end_battery"] = 93.8; trip3[":energy_used"] = 1.6; trip3[":distance_m"] = 700;
    trip3[":avg_speed"] = 4.3; trip3[":notes"] = ""; trip3[":favorite"] = 0; trip3[":photo"] = "";

    QVariantMap trip4;
    trip4[":date"] = "2025-07-04 13:20"; trip4[":duration"] = 9; trip4[":driver"] = "Luiza"; trip4[":location"] = "Oporto"; trip4[":vehicle"] = "FATEC-ACV 1";
    trip4[":start_battery"] = 93.5; trip4[":end_battery"] = 89.0; trip4[":energy_used"] = 1.9; trip4[":distance_m"] = 610;
    trip4[":avg_speed"] = 4.1; trip4[":notes"] = "Manual control"; trip4[":favorite"] = 0; trip4[":photo"] = "";

    QVariantMap trip5;
    trip5[":date"] = "2025-07-05 14:10"; trip5[":duration"] = 14; trip5[":driver"] = "Luis"; trip5[":location"] = "Oporto"; trip5[":vehicle"] = "FATEC-ACV 1";
    trip5[":start_battery"] = 97.0; trip5[":end_battery"] = 91.5; trip5[":energy_used"] = 2.2; trip5[":distance_m"] = 940;
    trip5[":avg_speed"] = 4.0; trip5[":notes"] = "Autonomous driving demo"; trip5[":favorite"] = 1; trip5[":photo"] = "";

    QVariantMap trip6;
    trip6[":date"] = "2025-07-06 16:00"; trip6[":duration"] = 13; trip6[":driver"] = "Jorge"; trip6[":location"] = "Oporto"; trip6[":vehicle"] = "FATEC-ACV 1";
    trip6[":start_battery"] = 91.0; trip6[":end_battery"] = 85.2; trip6[":energy_used"] = 2.1; trip6[":distance_m"] = 880;
    trip6[":avg_speed"] = 4.1; trip6[":notes"] = ""; trip6[":favorite"] = 0; trip6[":photo"] = "";

    QVariantMap trip7;
    trip7[":date"] = "2025-07-07 08:40"; trip7[":duration"] = 11; trip7[":driver"] = "Rui"; trip7[":location"] = "Oporto"; trip7[":vehicle"] = "FATEC-ACV 1";
    trip7[":start_battery"] = 94.5; trip7[":end_battery"] = 90.7; trip7[":energy_used"] = 1.4; trip7[":distance_m"] = 650;
    trip7[":avg_speed"] = 3.6; trip7[":notes"] = "Early morning quick run"; trip7[":favorite"] = 0; trip7[":photo"] = "";

    QVariantMap trip8;
    trip8[":date"] = "2025-07-08 12:30"; trip8[":duration"] = 17; trip8[":driver"] = "Luiza"; trip8[":location"] = "Oporto"; trip8[":vehicle"] = "FATEC-ACV 1";
    trip8[":start_battery"] = 89.8; trip8[":end_battery"] = 82.0; trip8[":energy_used"] = 2.9; trip8[":distance_m"] = 1120;
    trip8[":avg_speed"] = 4.0; trip8[":notes"] = "Longest continuous run"; trip8[":favorite"] = 1; trip8[":photo"] = "";

    QVariantMap trip9;
    trip9[":date"] = "2025-07-09 15:05"; trip9[":duration"] = 10; trip9[":driver"] = "Luis"; trip9[":location"] = "Oporto"; trip9[":vehicle"] = "FATEC-ACV 1";
    trip9[":start_battery"] = 96.2; trip9[":end_battery"] = 93.0; trip9[":energy_used"] = 1.1; trip9[":distance_m"] = 590;
    trip9[":avg_speed"] = 3.5; trip9[":notes"] = ""; trip9[":favorite"] = 0; trip9[":photo"] = "";

    QVariantMap trip10;
    trip10[":date"] = "2025-07-10 17:20"; trip10[":duration"] = 13; trip10[":driver"] = "Jorge"; trip10[":location"] = "Oporto"; trip10[":vehicle"] = "FATEC-ACV 1";
    trip10[":start_battery"] = 88.7; trip10[":end_battery"] = 85.3; trip10[":energy_used"] = 1.2; trip10[":distance_m"] = 670;
    trip10[":avg_speed"] = 3.9; trip10[":notes"] = "Sensor calibration"; trip10[":favorite"] = 0; trip10[":photo"] = "";

    QList<QVariantMap> trips;
    trips << trip1 << trip2 << trip3 << trip4 << trip5 << trip6 << trip7 << trip8 << trip9 << trip10;

    for (const auto& trip : trips) {
        for (auto it = trip.constBegin(); it != trip.constEnd(); ++it) {
            query.bindValue(it.key(), it.value());
        }
        if (!query.exec()) {
            qWarning() << "ERROR: " << query.lastError().text();
            return false;
        }
    }

    qInfo() << "Trips table populated with sample data.";
    return true;
}
