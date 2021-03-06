/*
 Abstract:
 Convenience methods added to UITextView
 to set it up for attributed text
 */

import UIKit

extension UITextView {
    
    func setDefaultsForAICAttributedTextView() {
        backgroundColor = .clear
        isScrollEnabled = false
        isEditable = false
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}
