//
//  AudioBookViewController.swift
//  kannada
//
//  Created by PraveenH on 04/05/20.
//  Copyright © 2020 books. All rights reserved.
//

import UIKit
import AVFoundation


class AudioBookViewController: UIViewController {
    @IBOutlet weak var padlock: CircleView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var animationview: UIView!
    @IBOutlet weak var ibAudioSliderBar: CustomUISlider!
    @IBOutlet weak var ibBooNameLbl: UILabel!
    @IBOutlet weak var ibPlayBtn: UIButton!
    
    
    var player : AVPlayer?
    private var playbackLikelyToKeepUpContext = 0
    var values = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureTableView()
        
        let urlString = "http://softwaresolutionpvt.com/bookapp/audiobooks/%E0%B2%B5%E0%B3%86%E0%B2%82%E0%B2%95%E0%B2%9F%E0%B2%B6%E0%B2%BE%E0%B2%AE%E0%B2%BF%E0%B2%AF%20%E0%B2%AA%E0%B3%8D%E0%B2%B0%E0%B2%A3%E0%B2%AF.mp3"
         
         values.append(urlString)
        values.append(urlString)
        values.append(urlString)
         values.append(urlString)
        values.append(urlString)
        values.append(urlString)
         values.append(urlString)
        values.append(urlString)
        values.append(urlString)
         values.append(urlString)
        values.append(urlString)
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
            let urlString = "http://softwaresolutionpvt.com/bookapp/audiobooks/%E0%B2%B5%E0%B3%86%E0%B2%82%E0%B2%95%E0%B2%9F%E0%B2%B6%E0%B2%BE%E0%B2%AE%E0%B2%BF%E0%B2%AF%20%E0%B2%AA%E0%B3%8D%E0%B2%B0%E0%B2%A3%E0%B2%AF.mp3"
             guard let url = URL.init(string: urlString) else { return }
             let playerItem = AVPlayerItem.init(url: url)
             self.player = AVPlayer.init(playerItem: playerItem)
             self.player?.play()
             self.player?.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp", options: .new, context: &playbackLikelyToKeepUpContext)
          
        }
    }
    
    func addObserver() {
       // print(self.player?.volume)
         if let stime = self.player?.currentItem?.duration {
            let total = CMTimeGetSeconds(stime)
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            let formattedString = formatter.string(from: TimeInterval(total))!
            print(formattedString)
        }
        
        self.player?.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: .main, using: { time in
            if let duration = self.player?.currentItem?.duration {
                print(duration)
              let duration = CMTimeGetSeconds(duration), time = CMTimeGetSeconds(time)
                
                
              let progress = (time/duration)
              self.ibAudioSliderBar.value = Float(progress)
            }
        })
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &playbackLikelyToKeepUpContext {
            if  self.player?.currentItem?.isPlaybackLikelyToKeepUp ?? false {
                self.padlock.isAnimating = false
                self.padlock.isHidden = true
                 self.addObserver()
                print("loadingIndicatorView.stopAnimating()")
            } else {
               // loadingIndicatorView.startAnimating() or something else
                print("loadingIndicatorView.startAnimating()")
                self.padlock.isAnimating = true
            }
        }
    }
    
    
    
    @IBAction func didTapOnForwordBtn(_ sender: Any) {
        
    }
    
    
    @IBAction func didTapOnBackBtn(_ sender: Any) {
        
    }
    
     
}

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
        return values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getHistoryCell(indexPath: indexPath)
    }
    
    func getHistoryCell(indexPath: IndexPath) -> AudioBookCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "AudioBookCell", for: indexPath) as! AudioBookCell
        cell.selectionStyle = .none
        return cell
                  
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.padlock.isAnimating = true
        self.didTapOnPlayBtn(UIButton())
    }
    
}








class CustomUISlider : UISlider {

    override func trackRect(forBounds bounds: CGRect) -> CGRect {

        //keeps original origin and width, changes height, you get the idea
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 5.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }

    //while we are here, why not change the image here as well? (bonus material)
    override func awakeFromNib() {
        self.setThumbImage(UIImage(named: "sliderthumb"), for: .normal)
        super.awakeFromNib()
    }
}










extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 3) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat.pi * 2
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
}

class CircleView: UIView {

    var foregroundColor = UIColor.white
    var lineWidth: CGFloat = 3.0

    var isAnimating = false {
        didSet {
            if isAnimating {
                self.isHidden = false
                self.rotate360Degrees(duration: 1.0)
            } else {
                self.isHidden = true
                self.layer.removeAllAnimations()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        self.isHidden = true
        self.backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        let width = bounds.width
        let height = bounds.height
        let radius = (min(width, height) - lineWidth) / 2.0

        var currentPoint = CGPoint(x: width / 2.0 + radius, y: height / 2.0)
        var priorAngle = CGFloat(360)

        for angle in stride(from: CGFloat(360), through: 0, by: -2) {
            let path = UIBezierPath()
            path.lineWidth = lineWidth

            path.move(to: currentPoint)
            currentPoint = CGPoint(x: width / 2.0 + cos(angle * .pi / 180.0) * radius, y: height / 2.0 + sin(angle * .pi / 180.0) * radius)
            path.addArc(withCenter: CGPoint(x: width / 2.0, y: height / 2.0), radius: radius, startAngle: priorAngle * .pi / 180.0 , endAngle: angle * .pi / 180.0, clockwise: false)
            priorAngle = angle

            foregroundColor.withAlphaComponent(angle/360.0).setStroke()
            path.stroke()
        }
    }

}
