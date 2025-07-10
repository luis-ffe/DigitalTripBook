cmake_minimum_required(VERSION 3.16)

project(DigitalTripBook VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 QuickLayouts Sql Charts)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appDigitalTripBook
    main.cpp
    databasehandler.h
    databasehandler.cpp
)

qt_add_qml_module(appDigitalTripBook
    URI DigitalTripBook
    VERSION 1.0
    QML_FILES
        Main.qml
        HomePage.qml
        JourneysPage.qml
        MediaPage.qml
        StatisticsPage.qml
        TripDetailPage.qml
        StatisticItem.qml
        SimpleBarChart.qml
        SimpleLineChart.qml
    RESOURCES
        resources.qrc
)

# Crucially, tell your QML module what it depends on
# This helps with deployment of the QML plugins themselves
target_link_libraries(appDigitalTripBook
    PRIVATE Qt6::Quick
    PRIVATE Qt6::QuickControls2
    PRIVATE Qt6::QuickLayouts
    PRIVATE Qt6::Sql
    PRIVATE Qt6::Charts
)

# For Linux, it's often better to ensure that the QML plugins are copied to the build directory
# This step is often handled by `windeployqt` or `macdeployqt` automatically.
# On Linux, you might still encounter issues without manual steps or specific deployment tools.
# Let's add a post-build step that mimics what deploy tools do, if not using a specific deploy tool.

# This is a common pattern for Linux deployments to ensure QML plugins are available
# You might need to adjust the path to your Qt installation's qml directory

if (UNIX AND NOT APPLE)
    add_custom_command(TARGET appDigitalTripBook POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            $<TARGET_FILE_DIR:Qt6::qml/QtQuick/Controls/>
            $<TARGET_FILE_DIR:appDigitalTripBook>/qml/QtQuick/Controls
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            $<TARGET_FILE_DIR:Qt6::qml/QtQuick/Layouts/>
            $<TARGET_FILE_DIR:appDigitalTripBook>/qml/QtQuick/Layouts
        COMMENT "Copying Qt Quick Controls and Layouts QML plugins for deployment"
    )
endif()

set_target_properties(appDigitalTripBook PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)
install(TARGETS appDigitalTripBook
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Qt Creator defines a few variables that are useful for locating files.
# See https://doc.qt.io/qtcreator/creator-project-cmake.html for details.
set(CMAKE_AUTOUIC_SEARCH_PATHS ${CMAKE_CURRENT_SOURCE_DIR})
set(CMAKE_AUTORCC_OPTIONS "--name" "qml")

set(QT_QML_GENERATE_QMLLS_INI ON)
