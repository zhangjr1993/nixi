import UIKit

class CommunityConventionViewController: BaseViewController {
    
    private lazy var starryBackground: StarryBackgroundView = {
        let view = StarryBackgroundView()
        return view
    }()
    
    private lazy var headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "default_ai_header")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "AI社区公约"
        label.textColor = UIColor(hex: "F7CB9B")
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var conventionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 16)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.text = """
        社区是我们大家共有的环境，希望大家共同遵守这份公约。共同创造和努力，一起打造一个开放、包容的友善社区。

        请负责任地使用AI技术，发挥其正面价值，拒绝暴力行为。
        请不要引导AI进行可能影响用户身心健康的低俗、暴力对话，多多教它正确的进步。
        如遇不恰当的AI对话，不论是在App社区内还是外部平台，都需要大家积极举报，使AI技术得以充分发挥正面价值。
        请在App内进行反馈，协助我们有效的采取措施。
        
        我们会严肃对待一切违反社区公约的行为，并会采取相应措施，包括删除违规内容、暂停或终止用户账户，以维护社区的秩序和用户的权益。后续将根据大家的反馈和建议，调整和持续更新社区公约，并及时公布违规治理和处罚。
        """
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func setupUI() {
        super.setupUI()
        
        title = "AI社区公约"
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        view.addSubview(starryBackground)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(conventionTextView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        [starryBackground, scrollView, contentView, headerImageView, titleLabel, conventionTextView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            starryBackground.topAnchor.constraint(equalTo: view.topAnchor),
            starryBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            starryBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            starryBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerImageView.widthAnchor.constraint(equalToConstant: 300),
            headerImageView.heightAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: -20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            conventionTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            conventionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            conventionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            conventionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
}
