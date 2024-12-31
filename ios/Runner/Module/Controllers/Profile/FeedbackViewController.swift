import UIKit
import Photos

enum FeedbackType: String, CaseIterable {
    case bugReport = "功能异常"
    case featureRequest = "新功能建议"
    case other = "其它"
}

class FeedbackViewController: BaseViewController {
    private var selectedType: FeedbackType?
    private var selectedImage: UIImage?
    
    private lazy var typeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("选择问题类型", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        button.layer.cornerRadius = 8
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(typeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var typeArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.down")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 16)
        textView.layer.cornerRadius = 8
        textView.delegate = self
        textView.text = "请描述您的问题或建议..."
        textView.textColor = .gray
        return textView
    }()
    
    private lazy var wordCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 12)
        label.text = "0/200"
        label.textAlignment = .right
        return label
    }()
    
    private lazy var contactTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        textField.textColor = .white
        textField.font = .systemFont(ofSize: 16)
        textField.layer.cornerRadius = 8
        textField.placeholder = "请输入您的联系方式"
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        textField.leftViewMode = .always
        textField.delegate = self
        textField.returnKeyType = .done
        return textField
    }()
    
    private lazy var imageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("上传截图", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(imageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var imagePreviewView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("提交反馈", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "9F5CCB")
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 确保 tabBar 被隐藏
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        // 显示 tabBar
        tabBarController?.tabBar.isHidden = false
    }
    
    override func setupUI() {
        super.setupUI()
        title = "反馈"
        setupSubviews()
        setupConstraints()
    }
    
    private func setupSubviews() {
        [typeButton, textView, wordCountLabel, contactTextField, 
         imageButton, imagePreviewView, submitButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        typeButton.addSubview(typeArrowImageView)
        typeArrowImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            typeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            typeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            typeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            typeButton.heightAnchor.constraint(equalToConstant: 44),
            
            textView.topAnchor.constraint(equalTo: typeButton.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 150),
            
            wordCountLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 4),
            wordCountLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            
            contactTextField.topAnchor.constraint(equalTo: wordCountLabel.bottomAnchor, constant: 16),
            contactTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contactTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contactTextField.heightAnchor.constraint(equalToConstant: 44),
            
            imageButton.topAnchor.constraint(equalTo: contactTextField.bottomAnchor, constant: 16),
            imageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageButton.widthAnchor.constraint(equalToConstant: 100),
            imageButton.heightAnchor.constraint(equalToConstant: 44),
            
            imagePreviewView.centerYAnchor.constraint(equalTo: imageButton.centerYAnchor),
            imagePreviewView.leadingAnchor.constraint(equalTo: imageButton.trailingAnchor, constant: 16),
            imagePreviewView.widthAnchor.constraint(equalToConstant: 60),
            imagePreviewView.heightAnchor.constraint(equalToConstant: 60),
            
            submitButton.topAnchor.constraint(equalTo: imageButton.bottomAnchor, constant: 32),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 44),
            
            typeArrowImageView.centerYAnchor.constraint(equalTo: typeButton.centerYAnchor),
            typeArrowImageView.trailingAnchor.constraint(equalTo: typeButton.trailingAnchor, constant: -12),
            typeArrowImageView.widthAnchor.constraint(equalToConstant: 16),
            typeArrowImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    @objc private func typeButtonTapped() {
        let alert = UIAlertController(title: "选择问题类型", message: nil, preferredStyle: .actionSheet)
        
        FeedbackType.allCases.forEach { type in
            let action = UIAlertAction(title: type.rawValue, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.selectedType = type
                self.typeButton.setTitle(type.rawValue, for: .normal)
                self.typeButton.setTitleColor(.white, for: .normal)
                
                UIView.animate(withDuration: 0.2) {
                    self.typeArrowImageView.transform = .identity
                }
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel) { [weak self] _ in
            UIView.animate(withDuration: 0.2) {
                self?.typeArrowImageView.transform = .identity
            }
        })
        
        UIView.animate(withDuration: 0.2) {
            self.typeArrowImageView.transform = CGAffineTransform(rotationAngle: .pi)
        }
        
        present(alert, animated: true)
    }
    
    @objc private func imageButtonTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "拍照", style: .default) { [weak self] _ in
            self?.showImagePicker(sourceType: .camera)
        }
        
        let libraryAction = UIAlertAction(title: "从相册选择", style: .default) { [weak self] _ in
            self?.showImagePicker(sourceType: .photoLibrary)
        }
        
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    @objc private func submitTapped() {
        guard let type = selectedType else {
            showAlert(message: "请选择问题类型")
            return
        }
        
        guard let description = textView.text,
              !description.isEmpty,
              description != "请描述您的问题或建议..." else {
            showAlert(message: "请输入问题描述")
            return
        }
        
        guard let contact = contactTextField.text, !contact.isEmpty else {
            showAlert(message: "请输入联系方式")
            return
        }
        
        // 显示加载状态
        submitButton.isEnabled = false
        
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // 重置表单
            self.resetForm()
            
            // 显示成功提示
            self.showToast(message: "提交成功")
            
            // 恢复按钮状态
            self.submitButton.isEnabled = true
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 20
        toastLabel.clipsToBounds = true
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toastLabel)
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            toastLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            toastLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    private func resetForm() {
        // 重置问题类型
        selectedType = nil
        typeButton.setTitle("选择问题类型", for: .normal)
        typeButton.setTitleColor(.gray, for: .normal)
        
        // 重置描述文本
        textView.text = "请描述您的问题或建议..."
        textView.textColor = .gray
        wordCountLabel.text = "0/200"
        
        // 重置联系方式
        contactTextField.text = nil
        
        // 重置图片
        selectedImage = nil
        imagePreviewView.image = nil
        imagePreviewView.isHidden = true
    }
    
}

// MARK: - UITextViewDelegate
extension FeedbackViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .gray {
            textView.text = nil
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "请描述您的问题或建议..."
            textView.textColor = .gray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        wordCountLabel.text = "\(numberOfChars)/200"
        return numberOfChars <= 200
    }
}

// MARK: - UIImagePickerControllerDelegate
extension FeedbackViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            imagePreviewView.image = image
            imagePreviewView.isHidden = false
        }
        picker.dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension FeedbackViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

