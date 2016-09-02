//
//  NuevoLibro.swift
//  BuscadorLibros
//
//  Created by AlexGarcia on 8/16/16.
//  Copyright © 2016 AlexGarcia. All rights reserved.
//

import UIKit
import CoreData

class NuevoLibro: UIViewController {

    @IBOutlet weak var isbn: UITextField!
    @IBOutlet weak var tituloLbl: UILabel!
    @IBOutlet weak var autoresLbl: UITextView!
    
    @IBOutlet weak var portdaImg: UIImageView!
    
    @IBOutlet weak var btnRegistrar: UIBarButtonItem!
    
    var tvc : TVC? = nil
    
    var autoresArray : NSArray = []
    
    var contexto : NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        isbn.clearButtonMode = UITextFieldViewMode.Always
        
        btnRegistrar.enabled = false
        
        contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }

    @IBAction func limpiarBtn(sender: AnyObject) {
        isbn.text = ""
    }
    
    @IBAction func textFieldDidEndEditing(sender: UITextField) {
        sender.resignFirstResponder()
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + isbn.text!
        //978-84-376-0494-7
        let url = NSURL(string: urls)
        if url != nil {
            let datos : NSData? = NSData(contentsOfURL: url!)
            if datos != nil && datos!.length > 2{
                //let texto = NSString(data: datos!, encoding: NSUTF8StringEncoding)
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
                    let dico1 = json as! NSDictionary
                    
                    let dico2 = dico1["ISBN:" + isbn.text!] as! NSDictionary
                    
                    tituloLbl.text = dico2["title"] as? String
                    
                    autoresArray = (dico2["authors"] as? NSArray)!
                        //print("cant: \(autoresArray.count)")
                        var s = ""
                        for a in autoresArray {
                            let autor = a["name"] as! String
                            s = s + "\n" + autor
                            //print("autor:" + autor)
                    
                        autoresLbl.text = s
                    
                        let dico3 = dico2["cover"] as? NSDictionary
                        //print("dico3: \(dico3)")
                        if dico3 != nil {
                        
                            var c1 = ""
                        
                            if dico3!["large"] != nil {
                                c1 = dico3!["large"] as! String
                                print("large: " + c1)
                            }
                            else if dico3!["medium"] != nil {
                                c1 = dico3!["medium"] as! String
                                print("medium: " + c1)
                            }
                            else if dico3!["small"] != nil {
                                c1 = dico3!["small"] as! String
                                print("small: " + c1)
                            }
                        
                            let urlCover = NSURL(string: c1)
                            if urlCover != nil {
                                let dataCover : NSData? = NSData(contentsOfURL: urlCover!)
                                portdaImg.hidden = false
                                portdaImg.image = UIImage(data: dataCover!)
                            }
                            else {
                                portdaImg.hidden = true
                            }
                        }
                        else {
                            portdaImg.hidden = true
                        }
                        //print("Titulo: \(tituloLbl.text!)")
                        //print("Autores: \(autoresLbl.text!)")
                        
                        btnRegistrar.enabled = true
                    
                        }
                    }
                    catch _ {
                    
                    }
                
            }
            else {
                if datos!.length == 2 {
                    //resultado.text = "No se localizó el ISBN: " + isbn.text!
                    let alertEmpty = UIAlertController(title: "Mensaje",
                                                       message: "No se localizó el ISBN: " + isbn.text!,
                                                       preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "Ok",
                                                 style: UIAlertActionStyle.Default,
                                                 handler: nil)
                    alertEmpty.addAction(okAction)
                    self.presentViewController(alertEmpty,
                                               animated: true,
                                               completion: nil)
                }
                else {
                    //self.resultado.text = "Error en conexión. Verifique que este conectado a internet."
                    let alertEmpty = UIAlertController(title: "Mensaje",
                                                       message: "Error en conexión, Verifique conexión a internet" + isbn.text!,
                                                       preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "Ok",
                                                 style: UIAlertActionStyle.Default,
                                                 handler: nil)
                    alertEmpty.addAction(okAction)
                    self.presentViewController(alertEmpty,
                                               animated: true,
                                               completion: nil)
                }
            }
        }
        else {
            //resultado.text = "No se localizó el ISBN: " + isbn.text!
            let alertEmpty = UIAlertController(title: "Mensaje",
                                               message: "No se localizó el ISBN: " + isbn.text!,
                                               preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok",
                                         style: UIAlertActionStyle.Default,
                                         handler: nil)
            alertEmpty.addAction(okAction)
            self.presentViewController(alertEmpty,
                                       animated: true,
                                       completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func registrarNuevoLibro(sender: AnyObject) {
        
        let nuevoLibroEntidad = NSEntityDescription.insertNewObjectForEntityForName("Libro", inManagedObjectContext: contexto!)
        
        nuevoLibroEntidad.setValue(tituloLbl.text!, forKey: "titulo")
        nuevoLibroEntidad.setValue(isbn.text!, forKey: "isbn")
        
        if !portdaImg.hidden {
            // Si tiene portada y se tiene que guardar
            let imagen = portdaImg.image
            nuevoLibroEntidad.setValue(UIImagePNGRepresentation(imagen!), forKey: "portada")
        }
        
        //let conjunto = autoresArray as! Set<String>
        
        var autores = Set<NSObject>() //autoresArray.accessibilityAssistiveTechnologyFocusedIdentifiers()
        
        for autor in autoresArray {
            let autorEntidad = NSEntityDescription.insertNewObjectForEntityForName("Autor", inManagedObjectContext: contexto!)
            autorEntidad.setValue(autor["name"] as! String, forKey: "nombre")
            autores.insert(autorEntidad)
        }
        
        nuevoLibroEntidad.setValue(autores, forKey: "EscritoPor")

        do {
            try contexto?.save()
        }
        catch {
            
        }
        
        tvc!.registraLibro(tituloLbl.text!, isbn: isbn.text!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cancelNuevoLibro(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
