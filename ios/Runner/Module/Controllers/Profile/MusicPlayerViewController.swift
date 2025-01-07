import UIKit
import SnapKit
import AVFoundation
import MediaPlayer

class MusicPlayerViewController: UIViewController {
    
    // MARK: - Properties
    private var audioPlayer: AVAudioPlayer?
    private var audioModel: AudioModel
    private var timer: Timer?
    private var playlist: AudioPlaylist
    private var isAutoPlaying: Bool = false
    
    // 添加音频会话属性
    private var audioSession: AVAudioSession {
        return AVAudioSession.sharedInstance()
    }
    
    // MARK: - UI Components
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "music_background")
        return imageView
    }()
    
    private lazy var albumArtworkView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 75
        view.clipsToBounds = true
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return view
    }()
    
    private lazy var songTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white.withAlphaComponent(0.8)
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = .white.withAlphaComponent(0.3)
        slider.setThumbImage(UIImage(named: "slider_thumb"), for: .normal)
        return slider
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        label.text = "00:00"
        return label
    }()
    
    private lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        label.text = "00:00"
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "音频由AI生成，禁止利用从事违法活动"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        
        // 添加背景视图
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        backgroundView.layer.cornerRadius = 8
        label.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(-8)
        }
        
        // 确保文本在背景之上
        label.layer.zPosition = 1
        
        // 添加阴影效果
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.5
        
        return label
    }()
    
    private lazy var controlsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 40
        return stackView
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.5
        return button
    }()
    
    private lazy var previousButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.5
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.5
        return button
    }()
    
    // MARK: - Navigation Items
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.5
        return button
    }()
    
    // MARK: - Initialization
    init() {
        self.playlist = AudioPlaylist()
        if let currentAudio = playlist.getCurrentAudio() {
            self.audioModel = currentAudio
            print("✅ Successfully loaded initial audio: \(currentAudio.title)")
        } else {
            self.audioModel = .mockData
            print("⚠️ Using mock data as fallback")
        }
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupUI()
        setupConstraints()
        setupAudioSession()
        setupRemoteTransportControls()
        setupAudioPlayer()
        updateUIWithAudioModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 停止接收远程控制事件
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserDefaults.showAudioAlert {
            UserDefaults.showAudioAlert = true
            // 显示版权声明
            let copyrightAlert = CopyrightAlertView(frame: view.bounds)
            view.addSubview(copyrightAlert)
        }
        
    }
    
    private func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.title = "每日推荐"
    }
    
    // MARK: - Audio Setup
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    private func setupRemoteTransportControls() {
        // 开始接收远程控制事件
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        // 配置远程控制命令中心
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // 播放/暂停命令
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.playPauseButtonTapped()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.playPauseButtonTapped()
            return .success
        }
        
        // 上一首/下一首命令
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.previousButtonTapped()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.nextButtonTapped()
            return .success
        }
    }
    
    private func updateNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        
        // 设置歌曲标题
        nowPlayingInfo[MPMediaItemPropertyTitle] = audioModel.title
        
        // 设置艺术家
        nowPlayingInfo[MPMediaItemPropertyArtist] = audioModel.artist
        
        // 设置播放时长
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer?.duration
        
        // 设置当前播放位置
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer?.currentTime
                
        // 设置封面图片
        if let coverImage = UIImage(named: audioModel.coverImageName) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: coverImage.size) { _ in
                return coverImage
            }
        }
        
        // 更新锁屏界面信息
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupAudioPlayer() {
        guard let path = Bundle.main.path(forResource: audioModel.localPath, ofType: nil) else {
            print("音频文件不存在: \(audioModel.localPath)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            progressSlider.minimumValue = 0
            progressSlider.maximumValue = Float(audioPlayer?.duration ?? 0)
            progressSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
            
            totalTimeLabel.text = audioModel.formattedDuration
            
            // 更新锁屏界面信息
            updateNowPlayingInfo()
        } catch {
            print("音频播放器初始化失败: \(error)")
        }
    }
    
    private func updateUIWithAudioModel() {
        songTitleLabel.text = audioModel.title
        artistLabel.text = audioModel.artist
        
        // 更新背景图片
        if let bgImage = UIImage(named: audioModel.bgImageName) {
            backgroundImageView.image = bgImage
        }
        
        // 清除旧的封面图片
        albumArtworkView.subviews.forEach { $0.removeFromSuperview() }
        
        // 设置新的封面图片
        if let coverImage = UIImage(named: audioModel.coverImageName) {
            let imageView = UIImageView(image: coverImage)
            imageView.contentMode = .scaleAspectFill
            imageView.frame = albumArtworkView.bounds
            albumArtworkView.addSubview(imageView)
            
            // 添加布局约束
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        // 更新时间标签
        totalTimeLabel.text = audioModel.formattedDuration
    }
    
    // MARK: - Timer
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateProgress() {
        guard let player = audioPlayer else { return }
        currentTimeLabel.text = String(format: "%02d:%02d", Int(player.currentTime) / 60, Int(player.currentTime) % 60)
        progressSlider.value = Float(player.currentTime)
    }
    
    // MARK: - Actions
    @objc private func playPauseButtonTapped() {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            stopTimer()
        } else {
            audioPlayer?.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            startTimer()
        }
        updateNowPlayingInfo()
    }
    
    @objc private func previousButtonTapped() {
        if let previousAudio = playlist.previousAudio() {
            audioModel = previousAudio
            setupAudioPlayer()
            updateUIWithAudioModel()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            audioPlayer?.play()
            startTimer()
        }
    }
    
    @objc private func nextButtonTapped() {
        playNextAudio()
    }
    
    @objc private func sliderValueChanged(_ slider: UISlider) {
        audioPlayer?.currentTime = TimeInterval(slider.value)
        updateProgress()
    }
    
    private func playNextAudio() {
        if let nextAudio = playlist.nextAudio() {
            audioModel = nextAudio
            setupAudioPlayer()
            updateUIWithAudioModel()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            audioPlayer?.play()
            startTimer()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(albumArtworkView)
        view.addSubview(songTitleLabel)
        view.addSubview(artistLabel)
        view.addSubview(progressSlider)
        view.addSubview(currentTimeLabel)
        view.addSubview(totalTimeLabel)
        view.addSubview(subtitleLabel)
        
        controlsStackView.addArrangedSubview(previousButton)
        controlsStackView.addArrangedSubview(playPauseButton)
        controlsStackView.addArrangedSubview(nextButton)
        view.addSubview(controlsStackView)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        albumArtworkView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.width.height.equalTo(150)
        }
        
        songTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(albumArtworkView.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(20)
        }
        
        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(songTitleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
        }
        
        progressSlider.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(controlsStackView.snp.top).offset(-50)
        }
        
        currentTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(progressSlider)
            make.top.equalTo(progressSlider.snp.bottom).offset(8)
        }
        
        totalTimeLabel.snp.makeConstraints { make in
            make.right.equalTo(progressSlider)
            make.top.equalTo(progressSlider.snp.bottom).offset(8)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(40)
        }
        
        controlsStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.width.equalTo(200)
        }
    }
    
    // MARK: - Navigation Actions
    @objc private func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - AVAudioPlayerDelegate
extension MusicPlayerViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            playNextAudio()
        } else {
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            stopTimer()
        }
        updateNowPlayingInfo()
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        // 处理音频中断（如来电）
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        stopTimer()
        updateNowPlayingInfo()
    }
    
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        // 中断结束后恢复播放
        if flags == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
            player.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            startTimer()
            updateNowPlayingInfo()
        }
    }
} 
