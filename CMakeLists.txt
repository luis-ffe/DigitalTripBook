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
        FocusHelper.qml
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

if (UNIX AND NOT APPLE AND NOT ANDROID)
    # Find the Qt QML directory
    if(TARGET Qt6::qml)
        get_target_property(QT_QML_DIR Qt6::qml LOCATION)
        get_filename_component(QT_QML_DIR "${QT_QML_DIR}" DIRECTORY)
        
        add_custom_command(TARGET appDigitalTripBook POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_directory
                "${QT_QML_DIR}/QtQuick/Controls"
                $<TARGET_FILE_DIR:appDigitalTripBook>/qml/QtQuick/Controls
            COMMAND ${CMAKE_COMMAND} -E copy_directory
                "${QT_QML_DIR}/QtQuick/Layouts"
                $<TARGET_FILE_DIR:appDigitalTripBook>/qml/QtQuick/Layouts
            COMMENT "Copying Qt Quick Controls and Layouts QML plugins for deployment"
        )
    endif()
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

# Platform-specific configuration
if(APPLE)
    # Check if targeting iOS
    if(IOS)
        # Set iOS deployment target
        # Use custom Info.plist
        set(CMAKE_XCODE_ATTRIBUTE_INFOPLIST_FILE ${CMAKE_CURRENT_SOURCE_DIR}/ios/Info.plist)
        set(CMAKE_OSX_DEPLOYMENT_TARGET "16.0" CACHE STRING "Minimum iOS version" FORCE)
        
        # Check if iOS directory exists
        if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/ios")
            message(STATUS "Creating iOS directory structure")
            file(MAKE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/ios")
        endif()
        
        # Info.plist path
        set(IOS_PLIST_PATH "${CMAKE_CURRENT_SOURCE_DIR}/ios/Info.plist")
        
        # Create Info.plist if it doesn't exist
        if(NOT EXISTS "${IOS_PLIST_PATH}")
            file(WRITE "${IOS_PLIST_PATH}" "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>CFBundleDisplayName</key>
    <string>Digital Trip Book</string>
    <key>CFBundleExecutable</key>
    <string>\${EXECUTABLE_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.luis.digitaltripbook</string>
    <key>CFBundleName</key>
    <string>\${PRODUCT_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${PROJECT_VERSION}</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>MinimumOSVersion</key>
    <string>16.0</string>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UIStatusBarHidden</key>
    <true/>
    <key>UIViewControllerBasedStatusBarAppearance</key>
    <false/>
</dict>
</plist>")
            message(STATUS "Created default Info.plist for iOS")
        endif()
        
        # Set the Info.plist location
        set(CMAKE_XCODE_ATTRIBUTE_INFOPLIST_FILE "${IOS_PLIST_PATH}")
        
        # Set architectures for device builds
        if(NOT CMAKE_OSX_SYSROOT MATCHES ".*simulator.*")
            set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "Build architectures for iOS" FORCE)
        else()
            # For simulator builds
            if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "arm64")
                set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE STRING "Build architectures for iOS Simulator" FORCE)
            else()
                set(CMAKE_OSX_ARCHITECTURES "x86_64" CACHE STRING "Build architectures for iOS Simulator" FORCE)
            endif()
            
            # Disable code signing for simulator builds
            set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")
            set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED "NO")
        endif()
        
        # Set bundle identifier
        set(CMAKE_XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.luis.digitaltripbook")
        
        # Set device family (1=iPhone, 2=iPad, 1,2=Universal)
        set(CMAKE_XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2")
        
        # Enable ARC
        set(CMAKE_XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC "YES")
        
        # Disable bitcode
        set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "NO")
        
        # Fix for stale focus objects - add a dummy text input in QML
        add_compile_definitions(QT_IOS_DISABLE_HIDPI=1)
        
        message(STATUS "Configured for iOS build with deployment target ${CMAKE_OSX_DEPLOYMENT_TARGET}")
    endif()
endif()

# Android-specific configuration
if(ANDROID)
    # Make sure the android directory exists
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/android")
        message(STATUS "Creating Android directory structure")
        file(MAKE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/android")
        file(MAKE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/android/res")
        file(MAKE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/android/res/values")
    endif()
    
    # Create AndroidManifest.xml if it doesn't exist
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/android/AndroidManifest.xml")
        file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/android/AndroidManifest.xml" "<?xml version=\"1.0\"?>
<manifest xmlns:android=\"http://schemas.android.com/apk/res/android\" 
    package=\"com.luis.digitaltripbook\" 
    android:versionName=\"${PROJECT_VERSION}\" 
    android:versionCode=\"1\" 
    android:installLocation=\"auto\">
    <uses-permission android:name=\"android.permission.INTERNET\"/>
    <uses-permission android:name=\"android.permission.WRITE_EXTERNAL_STORAGE\"/>
    <uses-permission android:name=\"android.permission.ACCESS_NETWORK_STATE\"/>
    <uses-feature android:glEsVersion=\"0x00020000\" android:required=\"true\"/>
    <application 
        android:name=\"org.qtproject.qt.android.bindings.QtApplication\" 
        android:label=\"Digital Trip Book\" 
        android:hardwareAccelerated=\"true\"
        android:theme=\"@style/AppTheme\">
        <activity 
            android:name=\"org.qtproject.qt.android.bindings.QtActivity\" 
            android:label=\"Digital Trip Book\" 
            android:configChanges=\"orientation|uiMode|screenLayout|screenSize|smallestScreenSize|layoutDirection|locale|fontScale|keyboard|keyboardHidden|navigation|mcc|mnc|density\" 
            android:screenOrientation=\"unspecified\" 
            android:launchMode=\"singleTop\" 
            android:exported=\"true\">
            <intent-filter>
                <action android:name=\"android.intent.action.MAIN\"/>
                <category android:name=\"android.intent.category.LAUNCHER\"/>
            </intent-filter>
            <meta-data android:name=\"android.app.lib_name\" android:value=\"appDigitalTripBook\"/>
            <meta-data android:name=\"android.app.extract_android_style\" android:value=\"minimal\"/>
        </activity>
    </application>
    <supports-screens 
        android:largeScreens=\"true\" 
        android:normalScreens=\"true\" 
        android:anyDensity=\"true\" 
        android:smallScreens=\"true\"/>
</manifest>")
        message(STATUS "Created default AndroidManifest.xml")
    endif()
    
    # Create styles.xml if it doesn't exist
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/android/res/values/styles.xml")
        file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/android/res/values/styles.xml" "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<resources>
    <style name=\"AppTheme\" parent=\"@android:style/Theme.DeviceDefault.Light.NoActionBar\">
        <item name=\"android:windowBackground\">@android:color/white</item>
    </style>
</resources>")
        message(STATUS "Created default styles.xml for Android")
    endif()
    
    # Set Android specific build options
    set(ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android CACHE INTERNAL "")
    set(QT_ANDROID_ABIS "armeabi-v7a;arm64-v8a;x86;x86_64" CACHE INTERNAL "")
    
    message(STATUS "Configured for Android build")
endif()
