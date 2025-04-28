//
//  Constants.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 26.04.2025.
//

import Foundation
import SwiftUI

// MARK: - App Constants
struct Constants {
    // MARK: - UI Constants
    struct UI {
        // General UI
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 4
        static let defaultPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        
        // Sizes
        struct Sizes {
            static let iconSize: CGFloat = 24
            static let thumbnailSize: CGFloat = 80
            static let thumbnailDetailsHeight: CGFloat = 240
        }
    }
    
    // MARK: - Audio Constants
    struct Audio {
        // Speech rate presets
        static let slowRate: Float = 0.5
        static let rate075: Float = 0.7
        static let normalRate: Float = 1.0
        static let rate15: Float = 1.5
        static let fastRate: Float = 2.0
    }
    
    // MARK: - Navigation
    struct Navigation {
        static let bookListTitle = String(localized: "Books")
    }
    
    // MARK: - Accessibility
    struct Accessibility {
        static let bookCoverImageLabel = String(localized: "Book Cover")
        static let bookTitleLabel = String(localized: "Book Title")
        static let chapterIndexLabel = String(localized: "Chapter Index")
        static let chapterTitleLabel = String(localized: "Chapter Title")
        static let chapterSummaryLabel = String(localized: "Chapter Summary")
        static let currentPositionSliderLabel = String(localized: "Current Position")
        static let chapterPickerLabel = String(localized: "Select Chapter")
        static let playButtonLabel = String(localized: "Play Summary")
        static let skipForwardButtonLabel = String(localized: "Forward 10 seconds")
        static let skipBackwardButtonLabel = String(localized: "Backward 5 seconds")
        static let nextChapterButtonLabel = String(localized: "Next chapter")
        static let prevChapterButtonLabel = String(localized: "Previous chapter")
    }
}
