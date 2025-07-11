import QtQuick 2.15
import QtQuick.Controls 2.15

// This component helps manage focus on iOS to avoid the "stale focus object" issue
Item {
    id: focusHelper
    
    // Create an invisible text field to manage focus properly on iOS
    TextInput {
        id: dummyTextField
        visible: false
        width: 0
        height: 0
        focus: false
        
        // Add accessibility properties
        Accessible.role: Accessible.NoRole
        Accessible.name: "Focus Helper Input"
        
        // Function to clear focus on iOS
        function clearFocus() {
            if (focus) {
                focus = false
            }
        }
    }
    
    // Called when navigating between pages to clear any active focus
    function resetFocus() {
        dummyTextField.clearFocus()
    }
    
    // Capture focus when the app goes into background
    Timer {
        id: focusResetTimer
        interval: 100
        onTriggered: {
            dummyTextField.clearFocus()
        }
    }
    
    // Public API
    function captureFocus() {
        dummyTextField.focus = true
        focusResetTimer.start()
    }
    
    // Use this on page transitions
    function prepareForNavigation() {
        captureFocus()
    }
}
