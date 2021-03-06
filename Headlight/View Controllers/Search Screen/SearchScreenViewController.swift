//
//  SearchScreenViewController.swift
//  Headlight
//
//  Created by iosdev on 25/04/2019.
//  Copyright © 2019 iSchoolMusical. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // this is the general viewcontroller for the search page.
    // the purpose of this class is to populate various tableviews at the page, and manage actions
    // happening in them.
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resultTableView: UITableView!
    
    var skills_title_text : String = NSLocalizedString("skills_title", comment: "")
    var searchContainers = [String]()
    var course_data : [CourseStruct.Course]?
    var all_skills = skills
    open var searchResultData : [CourseStruct.Course?]?
    private var searchString: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchContainers.append(self.skills_title_text)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.resultTableView.dataSource = self
        self.resultTableView.delegate = self
        self.searchResultData = []
        self.course_data = CoreDataHelper.listAllCourses()
        resultTableView.tableFooterView = UIView()
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white], for: .normal)
        
        self.searchBar.placeholder = NSLocalizedString("search_page_placeholder", comment: "")
        self.navigationItem.title = NSLocalizedString("search", comment:"" )
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.tableView{
            return searchContainers[section]
        }else{
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView{
            return 1
        }else{
            return (self.searchResultData?.count ?? 0)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView{
             return searchContainers.count
        }else {
            return 1
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchRow
            cell.cont_ref = self
            return cell
        }else{
            let cell = SearchResultCell(style: .subtitle, reuseIdentifier: nil)
            
            let course = self.searchResultData?.indices.contains(indexPath.row) ?? false ? self.searchResultData?[indexPath.row] : nil
            
            cell.textLabel?.text = course?.name ?? ""
            cell.detailTextLabel?.text = course?.description ?? ""
            cell.course = course
            return cell
        }
    }
    
    // open the course page when clicked in search
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if tableView == self.resultTableView{
           performSegue(withIdentifier: "courseSegue", sender: self)
        }
    }
    
    // here is the prepare function Hamed mentioned, not sure if needed
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! CoursePageViewController
        let course = searchResultData?[self.resultTableView.indexPathForSelectedRow?.row ?? 0]
        
        viewController.course = course
    }
    
    // the appendToSearchString function is bit of a legacy function. The original plan was to concatenate
    // the possible search strings into one long one, but the current implementation is better.
    
    func appendToSearchString(_ string: String){
        self.searchFunction(string)
    }
    
    
    // the searchfunction gets the list of all of the courses from core data helper class, and then
    // compares the search string with values inside of it.
    // it first clears the current search array (array that populates the resulting table view) and
    // then does the actual search.
    
    func searchFunction(_ searchString: String){
        self.clearSearchData()
        self.searchResultData =  course_data?.filter{
            
            if (($0.name ?? "").lowercased()).contains(searchString){
                return true
            }
            
        for skill in $0.skills?.gained ?? []{
            if(skill.contains(searchString)){
                return true
            }
            
        }
        for skill in $0.skills?.required ?? []{
            if(skill.contains(searchString)){
                return true
            }
            
        }
       return false
    }
        DispatchQueue.main.async {
            self.updateResultTableViewData()
        }
    }
    
    func updateResultTableViewData(){
        self.resultTableView?.reloadData()
      //  print("data reloaded..")
    }
    
    func clearSearchData(){
        self.searchResultData?.removeAll()
    }

}

// create some sort of extension for the search bar controller
// keeping it as an extension because makes it easier to find search bar functionalities on this page

extension SearchViewController: UISearchBarDelegate{
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.clearSearchData()
        self.updateResultTableViewData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    //    print("typing to searchbar")
        self.appendToSearchString(searchText.lowercased())
    }
}

