//
//  TVC.swift
//  BuscadorLibros
//
//  Created by AlexGarcia on 8/16/16.
//  Copyright © 2016 AlexGarcia. All rights reserved.
//

import UIKit
import CoreData

class TVC: UITableViewController {

    private var isbns : Array<Array<String>> = Array<Array<String>>()
    
    var contexto : NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Libros"

        contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let libroEntidad = NSEntityDescription.entityForName("Libro", inManagedObjectContext: contexto!)
        let peticion = libroEntidad?.managedObjectModel.fetchRequestTemplateForName("petISBNS")
        do {
            let libros  = try contexto?.executeFetchRequest(peticion!)
            for libro in libros! {
                let isbn = libro.valueForKey("isbn") as! String
                let titulo = libro.valueForKey("titulo") as! String
                
                isbns.append([titulo, isbn])
            }
        }
        catch {
            
        }
        /*
        isbns.append(["Cien años de soledad", "9788420471839"])
        isbns.append(["Java", "0131202367"])
        isbns.append(["Creating iOS 5 apps", "0321769600"])
        */
    }
    
    @IBAction func nuevoLibro(sender: AnyObject) {
        let nuevoLibroViewController = self.storyboard!.instantiateViewControllerWithIdentifier("NuevoLibro") as! NuevoLibro
        
        self.navigationController!.pushViewController(nuevoLibroViewController, animated: false)
    }
    
    func registraLibro(titulo: String, isbn: String) {
        isbns.append([titulo, isbn])
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return isbns.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Celda", forIndexPath: indexPath)

        cell.textLabel?.text = isbns[indexPath.row][0]
        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "Detail" {
            let libro = segue.destinationViewController as! ControlLibros
            let ip = self.tableView.indexPathForSelectedRow
            libro.isbn = self.isbns[ip!.row][1]
        }
        else {
            let nuevoLibro = segue.destinationViewController as! NuevoLibro
            nuevoLibro.tvc = self
        }
    }
    

}
