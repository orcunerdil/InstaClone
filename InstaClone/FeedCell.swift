//
//  FeedCell.swift
//  InstaClone
//
//  Created by Orçun Erdil on 19.05.2023.
//

import UIKit
import Firebase
import OneSignal

class FeedCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var likelbl: UILabel!
    @IBOutlet weak var documentIDLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func likeAction(_ sender: Any) {
        
        let firestoreDb = Firestore.firestore()
        
        if let likeCount = Int(likelbl.text!) {
            
            let likeStore = ["likes" : likeCount + 1] as [String:Any]
            
            firestoreDb.collection("Posts").document(documentIDLbl.text!).setData(likeStore,merge: true)

        }
        
        // PUSH NOTIFICATION
        
        
        // X kullancısı postunu begendi bildirimi gidecek.
        // postu beğenilen kullanıcının id sine ihtiyacımız var bunu da usernamelbl den kullanıcının mailini alıp firebaseden o maile karşılık gelen user id yi alabiliriz.
        
        
        let userEmail  = usernameLbl.text!
    
        firestoreDb.collection("PlayerId").whereField( "email",isEqualTo: userEmail).getDocuments { (snapshot,error) in
            if error == nil {
                if snapshot?.isEmpty == false && snapshot != nil {
                    
                    for document in snapshot!.documents {
                        
                       if let playerId = document.get("player_id") as? String {
                           OneSignal.postNotification(["contents": ["en":"\(Auth.auth().currentUser!.email!) postunu beğendi. "],"include_player_ids": ["\(playerId)"]])
                        }
                        
                    }
                    
                }
            }
        }
    }
}
