//
//  NowPlayingViewController.swift
//  Swift Radio
//
//  Created by Matthew Fecher on 7/22/15.
//  Copyright (c) 2015 MatthewFecher.com. All rights reserved.
//

import UIKit
import MediaPlayer
import GoogleMobileAds
import AVFoundation
import AVKit

//*****************************************************************
// Protocol
// Updates the StationsViewController when the track changes
//*****************************************************************

protocol NowPlayingViewControllerDelegate: class {
    func songMetaDataDidUpdate(track: Track)
    func artworkDidUpdate(track: Track)
    func trackPlayingToggled(track: Track)
}

//*****************************************************************
// NowPlayingViewController
//*****************************************************************

class NowPlayingViewController: UIViewController,GADNativeExpressAdViewDelegate,GADBannerViewDelegate,GADInterstitialDelegate{

    
     var interstitial: GADInterstitial?
    @IBOutlet weak var albumHeightConstraint: NSLayoutConstraint!
  
    
    @IBOutlet weak var playerview: YTPlayerView!
   
    var videoID : String!
    
    
    var soundFileURLRef: NSURL!
    
    
    
    var player: AVAudioPlayer?
    var addtionalParameter: [NSObject : AnyObject]?
    //
    ///
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
   
    @IBOutlet weak var stationDescLabel: UILabel!
    @IBOutlet weak var volumeParentView: UIView!
    @IBOutlet weak var slider = UISlider()
    
   //let Radioplayer  = AVPlayerView()
  let playerController = AVPlayerViewController()
    @IBOutlet var videoViewBox: UIView!
    var currentStation: RadioStation!
    var downloadTask: URLSessionDownloadTask?
    var iPhone4 = false
    var justBecameActive = false
    var newStation = true
    var nowPlayingImageView: UIImageView!
    
    var track: Track!
    var mpVolumeSlider = UISlider()
    
    weak var delegate: NowPlayingViewControllerDelegate?
    
   
    
    //banner 
    var banner = GADBannerView (adSize: kGADAdSizeSmartBannerPortrait)
    //banner
    func bannerView() {
        banner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner)
        banner.isHidden = false
        banner.delegate = self
        if #available(iOS 9.0, *) {
            banner.bottomAnchor.constraint(equalTo: view.bottomAnchor ).isActive = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 9.0, *) {
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 9.0, *) {
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
        banner.adUnitID = "ca-app-pub-1847361433397749/9068562513"
        banner.rootViewController = self
        banner.load(GADRequest())
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        banner.isHidden = false
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        banner.isHidden = true
        print("Error: \(error.localizedDescription)")
    }
 
    
    func loadad() {
        interstitial = createAndLoadInterstitial()
    }
    
    //setting
    func showEventsAcessDeniedAlert() {
        let alertController = UIAlertController(title: "No Internet Connection",
                                                message: "Please Connect Your Mobile Data or WIFI Connection",
                                                preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
            
            // THIS IS WHERE THE MAGIC HAPPENS!!!!
            if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(appSettings as URL)
            }
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    
    //*****************************************************************
    // MARK: - ViewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Setup handoff functionality - GH
        // Display the intertitial ad
      
        if connectedToNetwork() == true {
        Timer.scheduledTimer(timeInterval: TimeInterval(120), target: self, selector: #selector(NowPlayingViewController.loadad), userInfo: nil, repeats: true)
        bannerView()
            
        }
        else {
            showEventsAcessDeniedAlert()
        }
        
     

        // Set View Title
        self.title = currentStation.stationName
        
        // Create Now Playing BarItem
        createNowPlayingAnimation()
        
        // Setup MPMoviePlayerController
        // If you're building an app for a client, you may want to
        // replace the MediaPlayer player with a more robust 
        // streaming library/SDK. Preferably one that supports interruptions, etc.
        // Most of the good streaming libaries are in Obj-C, however they
        // will work nicely with this Swift code. There is a branch using RadioKit if 
        // you need an example of how nicely this code integrates with libraries.
    
        
        // Notification for when app becomes active
        NotificationCenter.default.addObserver(self,
            selector: #selector(NowPlayingViewController.didBecomeActiveNotificationReceived),
            name: Notification.Name("UIApplicationDidBecomeActiveNotification"),
            object: nil)
              // Notification for AVAudioSession Interruption (e.g. Phone call)
        NotificationCenter.default.addObserver(self,
            selector: #selector(NowPlayingViewController.sessionInterrupted),
            name: Notification.Name.AVAudioSessionInterruption,
            object: AVAudioSession.sharedInstance())
        
        // Check for station change
     
        
        // Setup slider
        setupVolumeSlider()
        setupPlayer()
        
    }
    
    func didBecomeActiveNotificationReceived() {
        // View became active
       
        justBecameActive = true
      
    }
    
    deinit {
        // Be a good citizen
        NotificationCenter.default.removeObserver(self,
            name: Notification.Name("UIApplicationDidBecomeActiveNotification"),
            object: nil)
       
        NotificationCenter.default.removeObserver(self,
            name: Notification.Name.AVAudioSessionInterruption,
            object: AVAudioSession.sharedInstance())
    }
    
    //*****************************************************************
    // MARK: - Setup
    //*****************************************************************
    
    func setupPlayer() {
     
     playerview.load(withVideoId: currentStation.stationStreamURL)
    
        
    }
    
   
    
    
    
 
  
    func setupVolumeSlider() {
        // Note: This slider implementation uses a MPVolumeView
        // The volume slider only works in devices, not the simulator.
        volumeParentView.backgroundColor = UIColor.clear
        let volumeView = MPVolumeView(frame: volumeParentView.bounds)
        for view in volumeView.subviews {
            let uiview: UIView = view as UIView
            if (uiview.description as NSString).range(of: "MPVolumeSlider").location != NSNotFound {
                mpVolumeSlider = (uiview as! UISlider)
            }
        }
        
        let thumbImageNormal = UIImage(named: "slider-ball")
        slider?.setThumbImage(thumbImageNormal, for: .normal)
        
    }
    
    func stationDidChange() {
      
    
    
        
    }
    
    //*****************************************************************
    // MARK: - Player Controls (Play/Pause/Volume)
    //*****************************************************************
    
    @IBAction func playPressed() {
        track.isPlaying = true
        playButtonEnable(enabled: false)
       // Radioplayer.play()
      
        
        // songLabel Animation
      
        
        // Start NowPlaying Animation
        nowPlayingImageView.startAnimating()
        
        // Update StationsVC
        self.delegate?.trackPlayingToggled(track: self.track)
    }
    
      
    @IBAction func volumeChanged(_ sender:UISlider) {
        mpVolumeSlider.value = sender.value
    }
    
    //*****************************************************************
    // MARK: - UI Helper Methods
    //*****************************************************************
    
    func optimizeForDeviceSize() {
        

    }
    
    func playButtonEnable(enabled: Bool = true) {
        if enabled {
            playButton.isEnabled = true
            pauseButton.isEnabled = false
            track.isPlaying = false
        } else {
            playButton.isEnabled = false
            pauseButton.isEnabled = true
            track.isPlaying = true
        }
    }
    
    func createNowPlayingAnimation() {
        
        // Setup ImageView
        nowPlayingImageView = UIImageView(image: UIImage(named: "NowPlayingBars-3"))
        nowPlayingImageView.autoresizingMask = []
        nowPlayingImageView.contentMode = UIViewContentMode.center
        
        // Create Animation
        nowPlayingImageView.animationImages = AnimationFrames.createFrames()
        nowPlayingImageView.animationDuration = 0.7
        
        // Create Top BarButton
        let barButton = UIButton(type: UIButtonType.custom)
        barButton.frame = CGRect(x: 0,y: 0,width: 40,height: 40);
        barButton.addSubview(nowPlayingImageView)
        nowPlayingImageView.center = barButton.center
        
        let barItem = UIBarButtonItem(customView: barButton)
        self.navigationItem.rightBarButtonItem = barItem
        
    }
    
    func startNowPlayingAnimation() {
        nowPlayingImageView.startAnimating()
    }
    
    //*****************************************************************
    // MARK: - Album Art
    //*****************************************************************
    

    
  
    
    //*****************************************************************
    // MARK: - Segue
    //*****************************************************************
    
    
    
 
       
    //*****************************************************************
    // MARK: - MPNowPlayingInfoCenter (Lock screen)
    //*****************************************************************
    
    
    //*****************************************************************
    // MARK: - AVAudio Sesssion Interrupted
    //*****************************************************************
    
    // Example code on handling AVAudio interruptions (e.g. Phone calls)
    func sessionInterrupted(notification: NSNotification) {
        if let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber{
            if let type = AVAudioSessionInterruptionType(rawValue: typeValue.uintValue){
                if type == .began {
                    print("interruption: began")
                    // Add your code here
                } else{
                    print("interruption: ended")
                    // Add your code here
                }
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Handoff Functionality - GH
    //*****************************************************************
    
    
    //Admob
    
    // MARK: - Help methods
    
    private func createAndLoadInterstitial() -> GADInterstitial? {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-1847361433397749/5900760578")
        
        guard let interstitial = interstitial else {
            return nil
        }
        
        let request = GADRequest()
        request.testDevices = [ kGADSimulatorID ]
        interstitial.load(request)
        interstitial.delegate = self
        
        return interstitial
    }
    
    // MARK: - GADInterstitialDelegate methods
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("Interstitial loaded successfully")
        ad.present(fromRootViewController: self)
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("Fail to receive interstitial")
    }

    
}
