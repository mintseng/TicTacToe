//
//  ViewController.swift
//  TicTacToe
//
//  Created by Vincent Tseng on 2/21/16.
//  Copyright © 2016 Vincent Tseng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // List of variables for Button and ImageView
    @IBOutlet weak var x0y0: UIImageView!
    @IBOutlet weak var x1y0: UIImageView!
    @IBOutlet weak var x2y0: UIImageView!
    @IBOutlet weak var x0y1: UIImageView!
    @IBOutlet weak var x1y1: UIImageView!
    @IBOutlet weak var x2y1: UIImageView!
    @IBOutlet weak var x0y2: UIImageView!
    @IBOutlet weak var x1y2: UIImageView!
    @IBOutlet weak var x2y2: UIImageView!
    @IBOutlet weak var b_x0y0: UIButton!
    @IBOutlet weak var b_x1y0: UIButton!
    @IBOutlet weak var b_x2y0: UIButton!
    @IBOutlet weak var b_x0y1: UIButton!
    @IBOutlet weak var b_x1y1: UIButton!
    @IBOutlet weak var b_x2y1: UIButton!
    @IBOutlet weak var b_x0y2: UIButton!
    @IBOutlet weak var b_x1y2: UIButton!
    @IBOutlet weak var b_x2y2: UIButton!
    @IBOutlet weak var reset_button: UIButton!
    
    // Label for telling user if game is won or lost.
    @IBOutlet weak var bottom_text: UILabel!
    var game_over = false
    var board = Dictionary<Int, Int>()
    var ai = false
    var list_image = Dictionary<Int, UIImageView>()
    var shapes = [1:"X",2:"O"]
    // ai_level: true -> not random, false -> random
    var ai_level = false
    
    // A tile has been clicked. Checks to see if game is still going and checks for win conditions.
    @IBAction func button_clicked(sender: UIButton) {
        if game_over {
            return
        }
        bottom_text.hidden = true
        if (board[sender.tag] == nil) && !ai && !game_over {
            setImage(sender.tag, player: 1)
            checkForWin(1, tile: sender.tag)
            aiTurn()
        }
    }
    
    // Reset button has been clicked. Reset everything.
    @IBAction func reset_clicked(sender: UIButton) {
        for image in list_image.values {
            image.image = nil
        }
        board = [:]
        game_over = false
        bottom_text.hidden = true
    }
    
    // Change the level of the AI. Currently there's RANDOM and STEVE (more aggressive).
    // In the future maybe implement flawless minimax algorithm.
    @IBAction func ai_level_button(sender: UIButton) {
        if ai_level {
            sender.setTitle("AI: Random", forState: UIControlState.Normal)
        } else {
            sender.setTitle("AI: Steve", forState: UIControlState.Normal)
        }
        ai_level = !ai_level
    }
    
    // Sets the images for the player at a certain tile.
    func setImage(tile: Int, player: Int) {
        let mark = shapes[player]
        board[tile] = player
        list_image[tile]!.image = UIImage(named: mark!)
    }
    
    // See if the passed in player has won given the tile.
    func checkForWin(player: Int, tile: Int) {
        if (checkDiagonal(player, tile: tile, board: board) ||
            checkHorizontal(player, tile: tile, board: board) ||
            checkVertical(player, tile: tile, board: board)) {
            let result: String
            if player == 1 {
                result = "won!"
            } else {
                result = "lost."
            }
            bottom_text.hidden = false
            bottom_text.text = "You \(result)"
            game_over = true
        }
    }
    
    // Checks horizontal win conditions for the tile's row.
    func checkHorizontal(player: Int, tile: Int, board: Dictionary<Int, Int>) -> Bool {
        let row = tile / 3
        for i in 0...2 {
            if board[row*3 + i] != player {
                return false
            }
        }
        return true
    }
    
    // Checks vertical win conditions for the tile's column.
    func checkVertical(player: Int, tile: Int, board: Dictionary<Int, Int>) -> Bool {
        let col = tile % 3
        for i in 0...2 {
            if board[col + 3*i] != player {
                return false
            }
        }
        return true
    }
    
    // Checks BOTH diagonal win conditions.
    func checkDiagonal(player: Int, tile: Int, board: Dictionary<Int, Int>) -> Bool {
        let row = tile / 3
        let col = tile % 3
        
        // top left to bottom right
        if (row == col) {
            for i in 0...2 {
                if board[i + 3 * i] != player {
                    return false
                }
            }
            return true
        }
        
        // top right to bottom left
        if (row == 2 - col) {
            for i in 0...2 {
                if board[(2 - i) + 3 * i] != player {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    // AI's turn to move. Moves according to AI level.
    func aiTurn() {
        if game_over {
            return
        } else if ai_level {
            ai_smart()
        } else {
            ai_stupid()
        }
    }
    
    // Not Steve.
    func ai_stupid() {
        var random_list:[Int] = []
        for i in 0...8 {
            if board[i] == nil {
                random_list.append(i)
            }
        }
        if random_list.count == 0 {
            tie()
        } else {
            let random = arc4random_uniform(UInt32(random_list.count))
            setImage(random_list[Int(random)], player: 2)
            checkForWin(2, tile: random_list[Int(random)])
        }
    }
    
    // Steve.
    func ai_smart() {
        // either minimax or just check for best state
        var new_board = board
        var win:[Int] = []
        var lose:[Int] = []
        for i in 0...8 {
            if new_board[i] == nil {
                new_board[i] = 1
                if (checkHorizontal(1, tile: i, board: new_board) ||
                    checkVertical(1, tile: i, board: new_board) ||
                    checkDiagonal(1, tile: i, board: new_board)) {
                    lose.append(i)
                }
                new_board[i] = 2
                if (checkHorizontal(2, tile: i, board: new_board) ||
                    checkVertical(2, tile: i, board: new_board) ||
                    checkDiagonal(2, tile: i, board: new_board)) {
                    win.append(i)
                    break
                }
                new_board[i] = nil
            }
        }
        if (win.count != 0) {
            setImage(win[0], player: 2)
            board[win[0]] = 2
            checkForWin(2, tile: win[0])
        } else if (lose.count != 0) {
            setImage(lose[0], player: 2)
            board[lose[0]] = 2
            checkForWin(2, tile: lose[0])
            
        } else {
            ai_stupid()
        }
    }
    
    // Checks to see if game has tied.
    func check_tie() {
        for key in board.keys {
            if board[key] == nil {
                return
            }
        }
        tie()
    }
    
    // Game has tied!
    func tie() {
        if (!game_over) {
            bottom_text.hidden = false
            bottom_text.text = "You tied!"
            game_over = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        bottom_text.adjustsFontSizeToFitWidth = true
        bottom_text.hidden = true
        list_image[0] = x0y0
        list_image[1] = x1y0
        list_image[2] = x2y0
        list_image[3] = x0y1
        list_image[4] = x1y1
        list_image[5] = x2y1
        list_image[6] = x0y2
        list_image[7] = x1y2
        list_image[8] = x2y2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

