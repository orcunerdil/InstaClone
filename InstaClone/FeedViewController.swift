//
//  FeedViewController.swift
//  InstaClone
//
//  Created by Orçun Erdil on 18.05.2023.
//

import UIKit
import Firebase
import SDWebImage
import OneSignal

class FeedViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   

    
    @IBOutlet weak var tableView: UITableView!
    
    var userEmail = [String]()
    var userComment = [String]()
    var likeCount = [Int]()
    var userImage = [String]()
    var documentIdArray = [String]()
    
    let firestoreDb = Firestore.firestore()

    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        super.viewDidLoad()
        let gestureKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureKeyboard)
        
        getDataFromFirestore()
        
      
        
        
        //PLAYER ID
        //Uygulamaya giriş yapan kullacının ID sini aldık playerId de depoladık
        //Id yi firebasede PlayerId adında bir collection açarak email-player_id şeklinde depoladık
        //uygulama çalıştığında direkt olarak kullanıcının id sini firebase e kayıt etmiş olacağız.
        
        let status = OneSignal.getDeviceState()
        let playerId = status!.userId
       
        
        if let playerNewId = playerId {
            
            firestoreDb.collection("PlayerId").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { (snapshot,error) in
                if error == nil {
                    if snapshot?.isEmpty == false && snapshot != nil {
                        for document in snapshot!.documents {
                            if let playerIDFromFirebase = document.get("player_id") as? String {
                                let documentId = document.documentID
                                
                                if playerNewId != playerIDFromFirebase {
                                    let playerIdDictionary = ["email" : Auth.auth().currentUser!.email!, "player_id" : playerNewId ] as! [String:Any]
                                    
                                    self.firestoreDb.collection("PlayerId").addDocument(data: playerIdDictionary) { (error) in
                                        if error != nil {
                                            print(error!.localizedDescription)
                                        }
                                    }
                                    
                                }

                            }
                        }
                    } else {
                        //Snapshot boşsa
                        let playerIdDictionary = ["email" : Auth.auth().currentUser!.email!, "player_id" : playerNewId ] as! [String:Any]
                        
                        self.firestoreDb.collection("PlayerId").addDocument(data: playerIdDictionary) { (error) in
                            if error != nil {
                                print(error!.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)

    }
    
    func getDataFromFirestore(){
        
      /*  let settings = firestoreDb.settings
        firestoreDb.settings = settings */

        firestoreDb.collection("Posts").order(by: "date",descending: true).addSnapshotListener { (snapshot, error) in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    self.userEmail.removeAll(keepingCapacity: false)
                    self.userComment.removeAll(keepingCapacity: false)
                    self.likeCount.removeAll(keepingCapacity: false)
                    self.userImage.removeAll(keepingCapacity: false)
                    self.documentIdArray.removeAll(keepingCapacity: false)
                    
                    for document in snapshot!.documents {
                      
                        let documentID = document.documentID
                        self.documentIdArray.append(documentID)
                        
                        if let postedBy = document.get("postedBy") as? String{
                            self.userEmail.append(postedBy)
                        }
                        if let postedComment = document.get("postComment") as? String{
                            self.userComment.append(postedComment)
                        }
                        if let likes = document.get("likes") as? Int{
                            self.likeCount.append(likes)
                        }
                        if let imageUrl = document.get("imageurl") as? String{
                            self.userImage.append(imageUrl)
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userEmail.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedCell
        cell.usernameLbl.text = userEmail[indexPath.row]
        cell.likelbl.text = String(likeCount[indexPath.row])
        cell.commentLbl.text = userComment[indexPath.row]
        cell.userImageView.sd_setImage(with: URL(string: self.userImage[indexPath.row]))
        cell.documentIDLbl.text = documentIdArray[indexPath.row]
        return cell
        
    }

}
