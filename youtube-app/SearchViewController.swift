//
//  SearchViewController.swift
//  youtube-app
//
//  Created by Nhat Ton on 13/2/18.
//  Copyright © 2018 Nhat Ton. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController, URLSessionDataDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var inputQuery: UITextField!
    @IBOutlet weak var progressView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    var buffer: NSMutableData!
    var searchResults: SearchResults!
    var queries: [String] = [String]()
    
    var queryObject: NSManagedObject!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResults = SearchResults()
        tableView.dataSource = self
        tableView.delegate = self
        fetchData()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func search(_ sender: Any) {
        let key:String = "AIzaSyDXhi3vzVS1a9V1jDOnB8Zc_TVwNKxnZlk"
        let query:String = inputQuery.text!
        let url:URL = URL(string: "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=25&q=\(query)&key=\(key)")!
        
        progressView.startAnimating()
        self.buffer = NSMutableData()
        let defaultConfigObject:URLSessionConfiguration = URLSessionConfiguration.default
        let session:Foundation.URLSession =
            Foundation.URLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: OperationQueue.main)
        session.dataTask(with: url).resume()
        
        if !(sender is UITableView) {
            saveQuery(query: query)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if(error == nil){
            print("Download is Succesfull");
            print("Done with bytes " + String(buffer.length))
            processResponse(buffer)
        } else {
            print("Error %@",error!._userInfo!);
            progressView.stopAnimating();
        }
    }
    
    func processResponse(_ data:NSMutableData) {
        let results:NSDictionary = (try!
            JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
        let items: NSArray = results.object(forKey: "items") as! Array<AnyObject> as NSArray
        searchResults.videoTitles = [String]()
        searchResults.videoIds = [String]()
        for item in items as [AnyObject] {
            let id = item.object(forKey: "id") as AnyObject
            let videoId = id.object(forKey: "videoId") as! String
            searchResults.videoIds.append(videoId)
            let snippet = item.object(forKey: "snippet") as AnyObject
            let title = snippet.object(forKey: "title") as! String
            searchResults.videoTitles.append(title)
        }
        progressView.stopAnimating();
        self.performSegue(withIdentifier: "search", sender: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "search" && self.searchResults != nil {
            (segue.destination as! MasterViewController).searchResults = searchResults
        }
        // Pass the selected object to the new view controller.
    }
    
    func saveQuery(query: String){
        let entityDescription = NSEntityDescription.entity(forEntityName: "Queries", in: context)
        let queryModel = NSManagedObject(entity: entityDescription!,
                                         insertInto: context)
        queryModel.setValue(query, forKey: "query")
        queryModel.setValue(CACurrentMediaTime().truncatingRemainder(dividingBy: 1), forKey: "timestamp")
        do {
            try context.save()
            insertNewObject(query)
        } catch {
            print("Failed saving")
        }
    }
    
    func fetchData(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Queries")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                self.queries.insert(data.value(forKey: "query") as! String, at: 0)
            }
        } catch {
            print("Failed")
        }
    }
    
    func insertNewObject(_ query: String) {
        queries.insert(query, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let object = queries[indexPath.row]
        cell.textLabel!.text = object.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        inputQuery.text = queries[indexPath.row]
        self.search(tableView)
    }
}

