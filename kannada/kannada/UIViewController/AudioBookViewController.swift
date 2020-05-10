//
//  AudioBookViewController.swift
//  kannada
//
//  Created by PraveenH on 04/05/20.
//  Copyright © 2020 books. All rights reserved.
//

import UIKit
import AVFoundation
import AuthenticationServices
import FBSDKLoginKit

class AudioBookViewController: UIViewController {
 
    @IBOutlet weak var padlock: CircleView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var ibFaceLoginView: UIView!
    @IBOutlet weak var ibcMoveAudioview: NSLayoutConstraint!
    @IBOutlet weak var ibAudioSliderBar: CustomUISlider!
    @IBOutlet weak var ibBooNameLbl: UILabel!
    @IBOutlet weak var ibPlayBtn: UIButton!
    @IBOutlet weak var ibAudioControllerview: UIView!
    
    @IBOutlet weak var ibCurrentplaytTimeLbl: UILabel!
    @IBOutlet weak var ibAudioDurationLbl: UILabel!
    
    var player : AVPlayer?
    private var playbackLikelyToKeepUpContext = 0
    var audioBooks = [AudioBook]()
    @IBOutlet weak var loginProviderStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureTableView()
        self.ibcMoveAudioview.constant = 124
        self.ibPlayBtn.isHidden = true
        self.getAudioFiles()
        self.setupProviderLoginView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
          self.facbookLogin()
    }
    
    //MARK:- Login Maintain
    func facbookLogin()  {
        
        let fbLoginButton = FBLoginButton()
        fbLoginButton.permissions = ["public_profile", "email"]
        fbLoginButton.delegate = self
        fbLoginButton.frame =  CGRect(x: 0, y: 0, width: self.ibFaceLoginView.frame.size.width, height: self.ibFaceLoginView.frame.size.height)
        
        self.ibFaceLoginView.addSubview(fbLoginButton)
        
    }

      func setupProviderLoginView() {
          let authorizationButton = ASAuthorizationAppleIDButton()
          authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
          self.loginProviderStackView.addArrangedSubview(authorizationButton)
      }
      
      /// - Tag: perform_appleid_request
      @objc func handleAuthorizationAppleIDButtonPress() {
          let appleIDProvider = ASAuthorizationAppleIDProvider()
          let request = appleIDProvider.createRequest()
          request.requestedScopes = [.fullName, .email]
          
          let authorizationController = ASAuthorizationController(authorizationRequests: [request])
          authorizationController.delegate = self
          authorizationController.presentationContextProvider = self
          authorizationController.performRequests()
      }
    
    func getAudioFiles()  {
      self.showeLoading()
        APIManager.getListOfAudioBooks { (error, result) in
           self.hideLoading()
           if let values = result as? Array<Any> {
               for item in values {
                 if let abook = AudioBook(dictionary: item as! NSDictionary) {
                      self.audioBooks.append(abook)
                  }
               }
               if self.audioBooks.count == 0 {
                   self.showeErorMsg("ಮಾಹಿತಿ ಲಭ್ಯವಿಲ್ಲ ದಯವಿಟ್ಟು ನಂತರ ಪ್ರಯತ್ನಿಸಿ")
               }else{
                   self.hideLoading()
                   self.tableView.reloadData()
               }
           }else{
               self.showeErorMsg("ಮಾಹಿತಿ ಲಭ್ಯವಿಲ್ಲ ದಯವಿಟ್ಟು ನಂತರ ಪ್ರಯತ್ನಿಸಿ")
           }
        }
    }
    
    @IBAction func didTapOnPlayBtn(_ sender: Any) {
        
        if ibPlayBtn.isSelected {
            self.ibPlayBtn.isSelected = false
            self.player?.pause()
        }else if player != nil {
            self.ibPlayBtn.isSelected = true
            self.player?.play()
        }else{
            self.ibPlayBtn.isSelected = true
            
            if let endpoint = audioBooks[(sender as! UIButton).tag].audiourl {
                let fullurl = APIList.BOOKBaseUrl + endpoint
                guard let urlS = URL.init(string: fullurl) else { return }

                let playerItem = AVPlayerItem.init(url:urlS)
                self.player = AVPlayer.init(playerItem: playerItem)
              
                self.player?.automaticallyWaitsToMinimizeStalling = true
                self.player?.playImmediately(atRate: 1.0)
                self.player?.play()
                self.player?.volume = 1.0   
                self.player?.addObserver(self, forKeyPath: "status", options: [], context: nil)
                self.player?.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp", options: .new, context: &playbackLikelyToKeepUpContext)
            }
            
        }
    }
    
    @IBAction func playerSeektoSlider(_ sender: Any) {
        let value = self.ibAudioSliderBar.value
          if let totalDuration = self.player?.currentItem?.duration {
            let durationToSeek = Float(CMTimeGetSeconds(totalDuration)) * value
            print(durationToSeek)
            self.player?.seek(to:CMTimeMakeWithSeconds(Float64(durationToSeek), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
 
        }
    }
    
    func addObserver() {
         if let stime = self.player?.currentItem?.duration {
            self.ibAudioDurationLbl.text = self.getLabelString(CMTimeGetSeconds(stime))
        }
        
        self.player?.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: .main, using: { time in
            if let duration = self.player?.currentItem?.duration {
                print(duration)
              let duration = CMTimeGetSeconds(duration), time = CMTimeGetSeconds(time)
              let progress = (time/duration)
              self.ibAudioSliderBar.value = Float(progress)
              self.ibCurrentplaytTimeLbl.text = self.getLabelString(time)
            }
        })
    }
    
    func getLabelString(_ stime : Float64) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        let audioDuration = formatter.string(from: TimeInterval(stime))!
        return audioDuration
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if context == &playbackLikelyToKeepUpContext {
            
            if  self.player?.currentItem?.isPlaybackLikelyToKeepUp ?? false {
                self.padlock.isAnimating = false
                self.padlock.isHidden = true
                self.ibPlayBtn.isHidden = false
                self.addObserver()
                self.player?.play()
                print("loadingIndicatorView.stopAnimating()")
            } else {
                print("loadingIndicatorView.startAnimating()")
                print(self.player?.reasonForWaitingToPlay ?? "")
                self.padlock.isAnimating = true
                self.ibPlayBtn.isHidden = true
            }
        }
    }
    
    @IBAction func didTapOnForwordBtn(_ sender: Any) {
        
    }
    
    
    @IBAction func didTapOnBackBtn(_ sender: Any) {
        
    }
    
}

//MARK:- UITableView Delegates
extension AudioBookViewController : UITableViewDelegate, UITableViewDataSource {
    
    func configureTableView()  {
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.registerCellforTableview()

    }
    
    func registerCellforTableview()  {
        let nib = UINib(nibName: "AudioBookCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "AudioBookCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getHistoryCell(indexPath: indexPath)
    }
    
    func getHistoryCell(indexPath: IndexPath) -> AudioBookCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "AudioBookCell", for: indexPath) as! AudioBookCell
       
        cell.ibTitleLabel.text = self.audioBooks[indexPath.row].title
        cell.ibSubTitleLabel.text = self.audioBooks[indexPath.row].subtitle
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
                  
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.padlock.isAnimating = true
        self.view.layoutIfNeeded()
        self.ibcMoveAudioview.constant = 0
        UIView.animate(withDuration: 0.5) { self.view.layoutIfNeeded() }

        let btn = UIButton()
        btn.tag = indexPath.row
        self.didTapOnPlayBtn(btn)
    }
}

//MARK:- Audio Book CellDelegate
extension AudioBookViewController: AudioBookCellDelegate {
    func didTapOnLikeBtn(_ cell : AudioBookCell) {
        cell.ibLikeBtn.setImage(UIImage(named: "hartfill"), for: .normal)
    }
    
    func didTapOnDownalodBtn(_ cell : AudioBookCell){
        
    }
}


//MARK:- Apple Login Delegate
extension AudioBookViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization){
        
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error){
        
    }
}


extension AudioBookViewController: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

//  MARK: - FaceBook LoginButtonDelegate
extension AudioBookViewController: LoginButtonDelegate {

    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
         print()
     }
     
     func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
         print()
     }
}
 
