#ifndef DATABASEHANDLER_H
#define DATABASEHANDLER_H

#include <QObject>
#include <QSqlDatabase>
#include <QVariant>

class DatabaseHandler : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseHandler(QObject *parent = nullptr);

    Q_INVOKABLE bool initDb();
    Q_INVOKABLE QVariantList getTrips(int page, int pageSize);
    Q_INVOKABLE QVariantMap getTripDetails(int tripId);
    Q_INVOKABLE bool updateTripFavoriteStatus(int tripId, bool isFavorite);
    Q_INVOKABLE bool updateTripNotes(int tripId, const QString &notes);

private:
    QSqlDatabase m_db;
    bool populateDb();
};

#endif
