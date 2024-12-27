import UIKit

class TopicHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "TopicHeaderView"
    
    private let topicLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let participantsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(topicLabel)
        addSubview(participantsLabel)
        addSubview(descriptionLabel)
        
        topicLabel.translatesAutoresizingMaskIntoConstraints = false
        participantsLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topicLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            topicLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            topicLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            participantsLabel.topAnchor.constraint(equalTo: topicLabel.bottomAnchor, constant: 8),
            participantsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            participantsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: participantsLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func configure(topic: String, participants: Int, description: String) {
        topicLabel.text = topic
        participantsLabel.text = "\(participants)人参与"
        descriptionLabel.text = description
    }
} 