//  ViewController.swift
//  Color Lock

import UIKit
import AVFoundation
import SAConfettiView
import Firebase

class ViewController: UIViewController {
    
    // Outlets
    @IBOutlet var buttonCollection: [UIButton]!
    @IBOutlet var playButtonImage: UIButton!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var playButtonInstructions: UIButton!
    @IBOutlet weak var viewLocksInstruction: UIButton!
    
    // Variables
    var ref: DatabaseReference!
    var buttonPressSound: AVAudioPlayer?
    var gameHasStarted: Bool = false
    var time: Int = 2
    var score: Int = 1 {
        // everytime score gets set
        didSet {
            growLabel()
            scoreLabel.text = formatScore(score: self.score)
        }
    }
    var queue: [Int] = [] {
        // everytime something gets added to the queue
        didSet {
            // loop through self
            for index in 0..<self.queue.count {
                // loop through buttons
                for button in buttonCollection {
                    // if we have a rand num equal to button tag
                    if button.tag == queue[index] {
                        // shake button
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(index)) {
                            // dispatching by .seconds(index) is what gives us the delay!
                            button.shake()
                            self.playSound(index: button.tag)
                        }
                    }
                }
            }
        }
    }
    var userInputArray: [Int] = []
    
    
    // functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // off
        enableButtons(condition: false)
        addConfetti()
        ref = Database.database().reference()
    }
    
    // start game
    @IBAction func playButtonPressed(_ sender: Any) {
        hideHomeScreenElements(condition: true)
        playGame()
    }
    
    // reset game functionality
    func playGame() {
        score = 1
        playRound()
    }
    
    // game iteration
    func playRound() {
        //off
        self.enableButtons(condition: false)
        self.turnLabel.textColor = UIColor.black
        turnLabel.text = "COPY THIS"
        
        // this is a nice pause for the user to read the prompt
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.queue = addToQueueArray()
            print("\(self.queue)")
            // on
            self.enableButtons(condition: true)
        }
        
        // this is a nice pause for the user to read the prompt
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.turnLabel.textColor = UIColor(red:0.25, green:0.53, blue:0.73, alpha:1.0)
            self.turnLabel.text = "YOUR TURN"
        }
    }
    
    // users input
    @IBAction func buttonPressed(_ sender: UIButton) {
        sender.shake()
        playSound(index: sender.tag)
        userInputArray.append(sender.tag)
        print("\(userInputArray)")
        checkInputResult()
    }
    
    func checkInputResult() {
        if(userInputArray.count == queue.count && userInputArray == queue) {
            resultCorrect()
        } else if (userInputArray.count == queue.count && userInputArray != queue) {
            resultIncorrect()
        } else if (userInputArray.count > queue.count) {
            resultIncorrect()
        }
    }
    
    // user correctly match queue
    func resultCorrect() {
        // reset userInputArray
        userInputArray.removeAll()
        turnLabel.textColor = UIColor(red:0.41, green:0.73, blue:0.25, alpha:1.0)
        turnLabel.text = "CORRECT"
        score = score * 2
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.playRound()
        }
    }
    
    // user incorrectly matched queue - game over
    func resultIncorrect() {
        
        for button in buttonCollection {
            print("\(String(describing: button.backgroundColor?.cgColor))")
        }
        
        writeToDatabase()
        userInputArray.removeAll()
        queue.removeAll()
        queueArray.removeAll()
        turnLabel.textColor = UIColor.red
        turnLabel.text = "INCORRECT"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // off
            self.enableButtons(condition: false)
            self.hideHomeScreenElements(condition: false)
            self.score = 1
            self.turnLabel.textColor = UIColor.black
            // reset button bgcolor
            for button in self.buttonCollection {
                button.backgroundColor = UIColor(red:0.96, green:0.81, blue:0.27, alpha:1.0)
            }
        }
    }
    
    // turn buttons on and off
    func enableButtons(condition: Bool) {
        for button in self.buttonCollection {
            button.isEnabled = condition
        }
    }
    
    // format the score
    func formatScore(score: Int) -> String{
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 4
        return formatter.string(from: NSNumber(value: score))!
    }
    
    // play sound
    func playSound(index: Int) {
        let path = Bundle.main.path(forResource: "\(index).wav", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            buttonPressSound = try AVAudioPlayer(contentsOf: url)
            buttonPressSound?.play()
        } catch {
            print("load file")
        }
    }
    
    // add confetti
    func addConfetti() {
        let confettiView = SAConfettiView(frame: self.view.bounds)
        confettiView.type = .Star
        
        view.addSubview(confettiView)
        view.sendSubviewToBack(confettiView)
        confettiView.startConfetti()
    }
    
    // label animations
    func growLabel() {
        UIView.animate(withDuration: 1.0) {
            self.scoreLabel.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        }
        UIView.animate(withDuration: 1.0) {
            self.scoreLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    func hideHomeScreenElements(condition: Bool) {
        playButtonImage.isHidden = condition
        playButtonInstructions.isHidden = condition
        viewLocksInstruction.isHidden = condition
        turnLabel.isHidden = !condition
    }
    
    func writeToDatabase() {
        var colorsArray: String = ""
        // add all button colors to array
        for button in buttonCollection {
            // get the buttons background color
            // convert it to a hexString
            colorsArray.append(button.backgroundColor!.hexString + " ")
        }
        // create helper data structure
        let data = [
            "score":  "\(formatScore(score: score))",
            "buttonColors": "\(colorsArray)"
        ]
        // send data structure to firebase
        ref?.child("Scores").childByAutoId().child("score").setValue(data)
    }

}

// extenstion for color conversions
extension UIColor {
    var hexString: String {
        let colorRef = cgColor.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha
        
        var color = String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
        
        if a < 1 {
            color += String(format: "%02lX", lroundf(Float(a)))
        }
        
        return color
    }
}
