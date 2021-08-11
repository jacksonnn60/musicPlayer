//
//  ViewController.swift
//  PlayerTask
//
//  Created by Jackie basss on 06.08.2021.
//

import UIKit
import MediaPlayer
import MediaToolbox
import AVFoundation

protocol PlayerViewConfigurationDelegate {
    func configureUI()
}

class PlayerViewController: UIViewController {
    
    // MARK: -@IBOutlets
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var songImageView: UIImageView!
    
    @IBOutlet weak var songTimeSlider: UISlider!
    @IBOutlet weak var songCurrentTimeLabel: UILabel!
    @IBOutlet weak var songTotalDurationLabel: UILabel!
    
    @IBOutlet weak var nextSongButton: UIButton!
    @IBOutlet weak var previousSongButton: UIButton!
    
    // MARK: -Variables
    
    var mediaPresenter: MediaPresenter!
    
    // MARK: -Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mediaPresenter.delegate = self
            
        self.configureUI()
        self.configure()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // if user play track from apple music, out player will show it...
        self.mediaPresenter.checkForCurrentIfExist()
        
    }
    
    
    // MARK: -Notification Actions
    
    private func configure() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.songTimeSlider.addTarget(self, action: #selector(changeTrackTimePosition(_:)), for: .allEvents)
        
        self.songNameLabel.isUserInteractionEnabled = true
        self.songNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openMusicLibrary)))
    }
    
    @objc func appMovedToBackground() {
        self.mediaPresenter.checkForCurrentIfExist()
    }
    
    @objc func changeTrackTimePosition(_ sender: UISlider) {
        
        // For EVERY value of slider, change time for currentTimeInterval, so the user can see the special moment of time he want to play.
        self.mediaPresenter.delegate.setCurrentTime(timeInterval: TimeInterval(Int(sender.value * 100)))
                
        if sender.state.rawValue == 0 {
            
            // When user take away his finger
            self.mediaPresenter.changeCurrentSongTime(for: sender.value)

            
            
            // Continue playing
            self.mediaPresenter.toogleMediaPlayerState()
            
        } else {
            self.mediaPresenter.suspend()
        }
        
    }
    
    @objc func openMusicLibrary() {
        self.mediaPresenter.getMediaLibrary()
    }
    
    
    // MARK: -@IBAction
    
    @IBAction func nextSong(_ sender: UIButton) {
        self.mediaPresenter.previousSong()
    }
    
    
    @IBAction func previousSong(_ sender: UIButton) {
        self.mediaPresenter.nextSong()
    }
    
    @IBAction func playButtonDidTap(_ sender: Any) {
        self.mediaPresenter.toogleMediaPlayerState()
    }
    
    @IBAction func uploadDidTap(_ sender: Any) {
        self.mediaPresenter.uploadCurrentSong()
        
        
        /// REASON
        let alert = UIAlertController(title: "Upload don't work", message: "Because of apple privacy 'DRM' for every song, assetUrl always will be equal nil...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Understand", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}


// MARK: -PlayerControllerDelegate

extension PlayerViewController: PlayerControllerDelegate {
    
    func changePlayButtonState(for playerStatus: PlayerStatus) {
        if playerStatus == .play {
            self.playButton.setImage(UIImage(systemName: "pause"), for: .normal)
            UIView.animate(withDuration: 0.4) {
                self.songImageView.transform = .identity
            }
        } else {
            self.playButton.setImage(UIImage(systemName: "play"), for: .normal)
            UIView.animate(withDuration: 0.4) {
                self.songImageView.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
            }
        }
    }
    
    func setCurrentTime(timeInterval: TimeInterval) {
        self.songCurrentTimeLabel.text = timeInterval.convertToMusicTimeFormat()
    }
    
    func setTimeLinePosition(time: Float) {
        self.songTimeSlider.value = time
    }
    
    func setSongInformation(currentSong: Song) {
        DispatchQueue.main.async {
            self.songNameLabel.text = currentSong.name
            self.artistNameLabel.text = currentSong.artist
            
            self.songImageView.image = currentSong.image
            self.songImageView.contentMode = .scaleToFill
            
            self.songTimeSlider.maximumValue = currentSong.totalDurationDigitalFormat

            self.songTotalDurationLabel.text = String(currentSong.totalDurationStringFormat)
        }
    }
    
    func showMediaLibrary(mediaPickerController: MPMediaPickerController) {
        self.present(mediaPickerController, animated: true, completion: nil)
    }
}

// MARK: -PalyerViewConfigurationDelegate

extension PlayerViewController: PlayerViewConfigurationDelegate {
    
    func configureUI() {
        
        self.playButton.layer.cornerRadius = 14
        self.playButton.setTitle("", for: .normal)
                
        self.uploadButton.layer.cornerRadius = 14
        self.uploadButton.setTitleColor(.darkGray, for: .normal)
        
        self.songImageView.layer.cornerRadius = 14
        self.songImageView.layer.borderColor = UIColor.systemBrown.cgColor
        self.songImageView.layer.borderWidth = 1.0
        self.songImageView.backgroundColor = .systemBrown
        
        
        
        
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 25, weight: .light)
        
        self.previousSongButton.setTitle("", for: .normal)
        self.previousSongButton.setImage(UIImage(systemName: "arrow.left")?.withConfiguration(imageConfiguration), for: .normal)
        
        self.nextSongButton.setTitle("", for: .normal)
        self.nextSongButton.setImage(UIImage(systemName: "arrow.forward")?.withConfiguration(imageConfiguration), for: .normal)
        
    }
    
}
