//
//  MediaPresenter.swift
//  PlayerTask
//
//  Created by Jackie basss on 07.08.2021.
//

import Foundation
import MediaPlayer

// MARK: -PROTOCOLS

protocol PlayerControllerDelegate: AnyObject {
    func showMediaLibrary(mediaPickerController: MPMediaPickerController)
    func setSongInformation(currentSong: Song)
    
    func setTimeLinePosition(time: Float)
    func setCurrentTime(timeInterval: TimeInterval)
    
    func changePlayButtonState(for playerStatus: PlayerStatus)
}

protocol MediaPresenterProtocol {
    var timer: Timer? { get set }
    var totalTime: TimeInterval? { get set }
    
    var mediaPicker: MPMediaPickerController? { get }
    func getMediaLibrary()
    func checkForCurrentIfExist()
}

protocol MediaPresenterActionProtocol {
    func changeCurrentSongTime(for sliderValue: Float)
    
    func toogleMediaPlayerState() // play, pause
    func uploadCurrentSong()
    
    func suspend() // suspend app while user moving slider...
    
    func nextSong()
    func previousSong()
}

// MARK: -PRESENTER

class MediaPresenter: NSObject, MediaPresenterProtocol, MediaPresenterActionProtocol {

    // MARK: -Variables
        
    var timer: Timer? = nil
    var totalTime: TimeInterval? = nil
    var mediaPicker: MPMediaPickerController?

    // Use SystemPlayer to play because of DRM (privacy) for every library song...
    private var mediaPlayer = MPMusicPlayerApplicationController.systemMusicPlayer
    
    private var mediaPlayerStatus: PlayerStatus = .stop {
        didSet {
            if mediaPlayerStatus == .stop {
                self.mediaPlayer.stop()
            } else {
                self.mediaPlayer.play()
            }
            
            self.delegate.changePlayButtonState(for: mediaPlayerStatus)
        }
    }
    
    private var timeLineValue: Float = 0.0 {
        didSet {
            self.delegate.setTimeLinePosition(time: self.timeLineValue)
        }
    }
    
    private var currentTimeInterval: TimeInterval? = nil {
        didSet {
            guard currentTimeInterval != nil else { return }
            self.delegate.setCurrentTime(timeInterval: currentTimeInterval!)
        }
    }
        
    var delegate: PlayerControllerDelegate!
    
    // MARK: -MediaPresenterProtocol
    
    func nextSong() {
        mediaPlayer.skipToNextItem()
        checkForCurrentIfExist()
    }
    
    
    func previousSong() {
        mediaPlayer.skipToPreviousItem()
        checkForCurrentIfExist()
    }
    
    func getMediaLibrary() {
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = false
        
        self.delegate.showMediaLibrary(mediaPickerController: mediaPicker)
    }
    
    func checkForCurrentIfExist() {
        guard let mediaItem = self.mediaPlayer.nowPlayingItem else { return }
        self.delegate.setSongInformation(currentSong: constructSong(from: mediaItem))

        self.setupCheckingTimer()
        self.mediaPlayerStatus = .play
    }
    
    
    // MARK: -MediaPresenterActionProtocol
    
    func changeCurrentSongTime(for sliderValue: Float) {
        let valueConvertedToTimeIntervalFloat = sliderValue * 100

        let timeInterval = TimeInterval(valueConvertedToTimeIntervalFloat)
        self.mediaPlayer.currentPlaybackTime = timeInterval
        self.setupCheckingTimer()
    }
    
    func suspend() {
        self.timer?.invalidate()
        self.mediaPlayer.stop()
        self.mediaPlayerStatus = .stop
    }
    
    func toogleMediaPlayerState() {
        if self.mediaPlayerStatus == .stop {
            self.mediaPlayerStatus = .play
        } else {
            self.timer?.invalidate()
            self.mediaPlayerStatus = .stop
        }
    }
    
    func uploadCurrentSong() {
        //  because of DRM (privacy) can not GET assetUrl, so the song can not be uploaded.
    }
    
    // MARK: -Additiong Actions
    
    private func setupCheckingTimer() {
        guard let totalTime = self.mediaPlayer.nowPlayingItem?.playbackDuration else { return }
        self.totalTime = totalTime
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(lookForCurrentTime), userInfo: nil, repeats: true)
    }
    
    @objc private func lookForCurrentTime() {
        let currentTimeInterval = self.mediaPlayer.currentPlaybackTime
        if totalTime == currentTimeInterval {
            
            self.mediaPlayerStatus = .stop
            self.timer?.invalidate()
            
            self.mediaPlayer.skipToNextItem()
            
        } else {
            self.timeLineValue = currentTimeInterval.convertToFloat()
            self.currentTimeInterval = currentTimeInterval
        }
    }
    
    private func constructSong(from mediaItem: MPMediaItem) -> Song {
        var song = Song(name: mediaItem.title!,
                        artist: mediaItem.albumArtist!,
                        
                        totalDurationStringFormat: mediaItem.playbackDuration.convertToMusicTimeFormat()
                        
                        ,totalDurationDigitalFormat: mediaItem.playbackDuration.convertToFloat())
        
        if let image = mediaItem.artwork?.image(at: CGSize(width: 100,
                                                           height: 100)) {
            song.image = image
        }
        
        return song
    }

}



// MARK: -MPMediaPickerProtocol

extension MediaPresenter: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        self.mediaPlayer.setQueue(with: mediaItemCollection)
        
        self.checkForCurrentIfExist()
        mediaPicker.dismiss(animated: true, completion: nil)
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
}
