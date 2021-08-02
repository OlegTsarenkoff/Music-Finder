//
//  TrackDetailView.swift
//  Music Finder
//
//  Created by Oleg Tsarenkoff on 20.07.21.
//

import UIKit
import SDWebImage
import AVKit

protocol TrackMovingDelegate {
    func moveBackForPreviousTrack() -> SearchViewModel.Cell?
    func moveForwardForPreviousTrack() -> SearchViewModel.Cell?
}

class TrackDetailView: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var miniTrackView: UIView!
    @IBOutlet weak var miniTrackImage: UIImageView!
    @IBOutlet weak var miniTrackTitle: UILabel!
    @IBOutlet weak var miniPlayButton: UIButton!
    @IBOutlet weak var miniForwardButton: UIButton!
    
    @IBOutlet weak var maximisedStackView: UIStackView!
    
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackTittleLabel: UILabel!
    @IBOutlet weak var artistTitleLabel: UILabel!
    
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    var delegate: TrackMovingDelegate?
    weak var tabBarDelegate: MainTabBarControllerDelegate?
    
    //MARK: - awakeFromNib
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let scale: CGFloat = 0.8
        trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        trackImageView.layer.cornerRadius = 10
        setupGestures()
    }
    
    //MARK: - Setup
    
    func set(viewModel: SearchViewModel.Cell) {
        miniTrackTitle.text = viewModel.trackName
        trackTittleLabel.text = viewModel.trackName
        artistTitleLabel.text = viewModel.artistName
        playTrack(previewUrl: viewModel.previewUrl)
        monitorStartTime()
        observePlayerCurrentTime()
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        miniPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
        
        let string600 = viewModel.iconUrlString?.replacingOccurrences(of: "100x100", with: "600x600")
        guard let url = URL(string: string600 ?? "") else { return }
        trackImageView.sd_setImage(with: url, completed: nil)
        miniTrackImage.sd_setImage(with: url, completed: nil)
        
        currentTimeSlider.setThumbImage(UIImage(systemName: "circle.fill"), for: .highlighted)
    }
    
    private func setupGestures() {
        miniTrackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximised)))
        miniTrackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissPan)))
    }
    
    
    private func playTrack(previewUrl: String?) {
        guard let url = URL(string: previewUrl ?? "") else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    //MARK: - Min and Max gestures
    
    @objc private func handleTapMaximised() {
        self.tabBarDelegate?.maximiseTrackDetailController(viewModel: nil)
    }
    
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            handlePanChanged(gesture: gesture)
        case .ended:
            handlePanEnded(gesture: gesture)
        @unknown default:
            print("default handlePan")
        }
    }
    
    private func handlePanChanged(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        let newAlpha = 1 + translation.y / 200
        self.miniTrackView.alpha = newAlpha < 0 ? 0 : newAlpha
        self.maximisedStackView.alpha = -translation.y / 200
    }
    
    private func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: {
                self.transform = .identity
                if translation.y < -200 || velocity.y < -500 {
                    self.tabBarDelegate?.maximiseTrackDetailController(viewModel: nil)
                } else {
                    self.miniTrackView.alpha = 1
                    self.maximisedStackView.alpha = 0
                }
            },
            completion: nil
        )
    }
    
    @objc private func handleDismissPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: self.superview)
            maximisedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        case .ended:
            let translation = gesture.translation(in: self.superview)
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 1,
                options: .curveEaseInOut,
                animations: {
                    self.maximisedStackView.transform = .identity
                    if translation.y > 50 {
                        self.tabBarDelegate?.minimiseTrackDetailController()
                    }
                },
                completion: nil
            )
        @unknown default:
            print("default handleDismissPan")
        }
    }
    
    //MARK: - Time setup
    
    private func monitorStartTime() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeTrackImageView()
            
        }
    }
    
    private func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.toDisplayString()
            
            let durationTime = self?.player.currentItem?.duration
            let currentDurationTimeText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()
            self?.durationLabel.text = "-\(currentDurationTimeText)"
            self?.updateCurrentTimeSlider()
        }
    }
    
    private func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
    }
    
    //MARK: - Animations
    
    private func enlargeTrackImageView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.trackImageView.transform = .identity
        }, completion: nil)
    }
    
    private func reduceTrackImageView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            let scale: CGFloat = 0.8
            self.trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
    }
    
    //MARK: - IBActions
    
    @IBAction func dragDownButtonTapped(_ sender: Any) {
        //self.removeFromSuperview()
        self.tabBarDelegate?.minimiseTrackDetailController()
        
    }
    
    @IBAction func handleCurrenTimeSlider(_ sender: Any) {
        let persontage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeUnSeconds = Float64(persontage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeUnSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    @IBAction func previousTrack(_ sender: Any) {
        let cellViewModel = delegate?.moveBackForPreviousTrack()
        guard let cellInfo = cellViewModel else { return }
        self.set(viewModel: cellInfo)
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            miniPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            enlargeTrackImageView()
        } else {
            player.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            miniPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            reduceTrackImageView()
        }
    }
    
    @IBAction func nextTrack(_ sender: Any) {
        let cellViewModel = delegate?.moveForwardForPreviousTrack()
        guard let cellInfo = cellViewModel else { return }
        self.set(viewModel: cellInfo)
    }
    
    @IBAction func handleVolumeSlider(_ sender: Any) {
        player.volume = volumeSlider.value
    }
}
