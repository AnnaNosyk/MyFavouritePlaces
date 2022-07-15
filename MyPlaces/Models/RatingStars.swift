//
//  RaitingStars.swift
//  MyFavouritePlaces
//
//  Created by Anna Nosyk on 12/07/2022.
//

import UIKit

@IBDesignable class RatingStars: UIStackView {
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    // count of stars
    @IBInspectable var starsCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }

    // for raiting in model
    var rating = 0 {
        didSet {
            
            updateButtonSelectionState()
        }
    }
    
    // array of all buttons
    private var ratingButtons = [UIButton]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    
   
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: - Action for buttons
    
    @objc func ratingButtonAction(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    //MARK: - Setup Buttons
    private func setupButtons() {
        
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        // Load button image
        
        let emptyStar = UIImage(systemName: Constants().emptyStarRating)
        let filledStar = UIImage(systemName: Constants().fullStarRating)
    
        for _ in 0..<starsCount {
            
            // Create the button
            let button = UIButton()
            
            // Set the button image
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
          
            // Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: starSize.height),
                button.widthAnchor.constraint(equalToConstant: starSize.width)
            ])
            
            // Setup the button action
            button.addTarget(self, action: #selector(ratingButtonAction(button:)), for: .touchUpInside)
            
            // Add the button to the stack
            addArrangedSubview(button)
            
            // Add the new button on the rating button array
            ratingButtons.append(button)
        }
        
        updateButtonSelectionState()
    }
    
    private func updateButtonSelectionState() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }


}
