#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QIcon>
#include <QQmlContext>
#include "databasehandler.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    // Set the Qt Quick Controls style to Material (supports customization)
    QQuickStyle::setStyle("Material");

    // Optional: Set application icon
    app.setWindowIcon(QIcon(":/icons/tripnot.png"));

    QQmlApplicationEngine engine;

    // Create and initialize the database handler
    DatabaseHandler dbHandler;
    dbHandler.initDb();

    // Expose the database handler to QML
    engine.rootContext()->setContextProperty("databaseHandler", &dbHandler);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("DigitalTripBook", "Main"); // This should match your QML module/folder setup

    return app.exec();
}
