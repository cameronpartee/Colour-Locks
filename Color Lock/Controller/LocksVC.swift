//  LocksVC.swift
//  Color Lock

import UIKit
import Firebase
import SAConfettiView

class LocksVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // outlets
    @IBOutlet weak var tableView: UITableView!
    
    // variables
    // to load DB data
    var scoreResults: [String] = []
    var colorsArray: [[String]] = []
    // firebase
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    var index = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addConfetti()
        // tableview
        tableView.dataSource = self
        tableView.delegate = self
        // firebase
        ref = Database.database().reference()
        // data
        updateDBOnChildAdd()
    }
    
    // add confetti
    func addConfetti() {
        let confettiView = SAConfettiView(frame: self.view.bounds)
        confettiView.type = .Star
        
        view.addSubview(confettiView)
        view.sendSubviewToBack(confettiView)
        confettiView.startConfetti()
    }
    
    // db pull
    func updateDBOnChildAdd() {
        // create a query
        let query = ref?.child("Scores").queryOrdered(byChild: "score")
        // on childAdded
        query?.observe(.childAdded, with: {(snapshot) in
            // loop through values
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let value = snap.value as? NSDictionary
                
                // get score
                let userScore = value!["score"]! as? String ?? ""
                // save score
                self.scoreResults.append(userScore)
                
                // get color
                let color = value!["buttonColors"]! as? String ?? ""
                let tempArray = color.components(separatedBy: " ")
                // save color
                self.colorsArray.append(tempArray)
                //print("\(self.colorsArray)")
                
                // tableview
                self.tableView.reloadData()
            }
        })
    }
    
    // tableview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? scoreCell {
            // set score
            cell.scoreLabel.text = scoreResults[indexPath.row]
            cell.scoreLabel2.text = scoreResults[indexPath.row]
            
            // for the buttons in the stackView
            for button in cell.buttonCollection {
                //
                if (button.tag == index) {
                    // set the color
                    button.backgroundColor = UIColor(hexString: colorsArray[indexPath.row][index])
                }
                // increment index
                index = index + 1
            }
            // reset index
            index = 0
            
            return cell
            
        } else {
            return scoreCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //Choose your custom row height
        return 60.0
    }
    
    @IBAction func playGameButtonPressed(_ sender: Any) {
         dismiss(animated: true, completion: nil)
    }
}


extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
