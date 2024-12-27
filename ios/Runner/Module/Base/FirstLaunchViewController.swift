//
//  FirstLaunchViewController.swift
//  AIChatGenie
//
//  Created by Bolo on 2024/11/11.
//

import UIKit

class FirstLaunchViewController: BaseViewController {
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 5
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .gray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var enterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("进入", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 22
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(enterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var privacyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("《隐私协议》", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(privacyButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var checkboxButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "checkbox_nor"), for: .normal)
        button.setImage(UIImage(named: "checkbox_sel"), for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(checkboxButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var privacyContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar = true
        setupUI()
    }
    
    // MARK: - UI Setup
    override func setupUI() {
        super.setupUI()
        
        // Add subviews
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(enterButton)
        view.addSubview(privacyContainer)
        
        privacyContainer.addSubview(checkboxButton)
        privacyContainer.addSubview(privacyButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            
            enterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enterButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100),
            enterButton.widthAnchor.constraint(equalToConstant: 200),
            enterButton.heightAnchor.constraint(equalToConstant: 44),
            
            privacyContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            privacyContainer.topAnchor.constraint(equalTo: enterButton.bottomAnchor, constant: 20),
            privacyContainer.heightAnchor.constraint(equalToConstant: 44),
            
            checkboxButton.leadingAnchor.constraint(equalTo: privacyContainer.leadingAnchor),
            checkboxButton.centerYAnchor.constraint(equalTo: privacyContainer.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            
            privacyButton.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 1),
            privacyButton.centerYAnchor.constraint(equalTo: privacyContainer.centerYAnchor),
            privacyButton.trailingAnchor.constraint(equalTo: privacyContainer.trailingAnchor),
            privacyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        setupScrollViewContent()
    }
    
    private func setupScrollViewContent() {
        let imageNames = ["launch_bg_01", "launch_bg_02", "launch_bg_03", "launch_bg_04", "launch_bg_05"]
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        for (index, imageName) in imageNames.enumerated() {
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            let xPosition = screenWidth * CGFloat(index)
            imageView.frame = CGRect(x: xPosition,
                                   y: 0,
                                   width: screenWidth,
                                   height: screenHeight)
            
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSize(width: screenWidth * CGFloat(imageNames.count),
                                      height: screenHeight)
    }
    
    // MARK: - Actions
    @objc private func enterButtonTapped() {
//        guard checkboxButton.isSelected else {
//            shakeCheckbox()
//            return
//        }
        
        UserDefaults.hasLaunched = true
        if let window = UIApplication.shared.windows.first {
            UIView.transition(with: window,
                            duration: 0.3,
                            options: .transitionCrossDissolve,
                            animations: {
                window.rootViewController = MainTabBarController()
            }, completion: nil)
        }
    }
    
    @objc private func privacyButtonTapped() {
        guard let url = URL(string: "https://your-privacy-policy-url.com") else { return }
        UIApplication.shared.open(url)
    }
    
    @objc private func checkboxButtonTapped() {
        checkboxButton.isSelected.toggle()
    }
    
    private func shakeCheckbox() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0]
        checkboxButton.layer.add(animation, forKey: "shake")
    }
}

// MARK: - UIScrollViewDelegate
extension FirstLaunchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / view.bounds.width))
        pageControl.currentPage = page
        
        // Show buttons only on the last page
        let isLastPage = page == 4
        enterButton.isHidden = !isLastPage
        privacyContainer.isHidden = !isLastPage
    }
} 
