

import UIKit
import Firebase
import FirebaseStorage
class UploadViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        uploadImage.isUserInteractionEnabled = true
        let gestureRec = UITapGestureRecognizer(target: self, action: #selector(choseImage))
        let gestureKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))

        uploadImage.addGestureRecognizer(gestureRec)
        view.addGestureRecognizer(gestureKeyboard)
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)

    }
    
    @objc func choseImage(){
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController,animated: true, completion: nil)
        
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        uploadImage.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true,completion: nil)
        
        
    }
    
    func makeAlert(title:String, error:String){
        
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okBtn)
        self.present(alert, animated: true)
        
    }

    @IBAction func saveBtnClicked(_ sender: Any) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let mediaFolder = storageRef.child("media")
        
        if let data = uploadImage.image?.jpegData(compressionQuality: 0.5) {
            
            let uuid = UUID().uuidString
            
            
            let imageRef = mediaFolder.child("\(uuid).jpg")
            imageRef.putData(data) { (metadata,error) in
                if error != nil {
                    self.makeAlert(title: "Error", error: error?.localizedDescription ?? "Error")
                }else {
                    imageRef.downloadURL { (url,error) in
                        
                        if error == nil {
                            let imageurl = url?.absoluteString
                        
                            //Database
                            
                            let firestoreDB = Firestore.firestore()
                            
                            var firestoreReferance : DocumentReference?
                            let firestorePost = ["imageurl" : imageurl!, "postedBy" : Auth.auth().currentUser!.email!, "postComment" : self.commentText.text!, "date" : FieldValue.serverTimestamp(), "likes" : 0 ] as [String:Any]
                            
                            firestoreReferance = firestoreDB.collection("Posts").addDocument(data: firestorePost, completion: { (error) in
                                if error != nil {
                                    self.makeAlert(title: "Error!", error: error?.localizedDescription ?? "Error")
                                }else {
                                    self.uploadImage.image = UIImage(named: "select.jpg")
                                    self.commentText.text = ""
                                    //tabbardaki ilk yere yani Feed ekranına götürür.
                                    self.tabBarController?.selectedIndex = 0
                                    
                                }
                            })
                            
                        }
                        
                    }
                }
            }
            
        }
        
        
    }
    

}
