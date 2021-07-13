//
//  ViewController.swift
//  GrandDispatchCenter-P9
//
//  Created by Łukasz Nycz on 13/07/2021.
//
import UIKit

class ViewController: UITableViewController {

    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIbuttons()
        performSelector(inBackground: #selector(fetchJson), with: nil)
       
    }
    
    @objc func refreshTable(){
        tableView.reloadData()
    }
    
    @objc func filteredCases() {
        let ac = UIAlertController(title: "Enter Your Filter", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
                  [weak self, weak ac] _ in
                  guard let answer = ac?.textFields?[0].text else { return }
                  self?.submit(answer)
              }
                ac.addAction(submitAction)
                present(ac, animated: true, completion: nil)
    }
    @objc func fetchJson() {
        let urlString: String
            
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    parse(json: data)
                    filteredPetitions = petitions
                        return
                    }
            }
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    func UIbuttons() {
        let creditsButton = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(credits))
       navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filteredCases))
        
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTable))
        navigationItem.rightBarButtonItems = [refresh, creditsButton]
    }
    func submit(_ answer:String) {
        filteredPetitions.removeAll(keepingCapacity: true)
        for petition in petitions {
            if petition.title.lowercased().contains(answer.lowercased()) {
                filteredPetitions.append(petition)
                
            }
        }
        petitions += filteredPetitions
        tableView.reloadData()
    }
    
    @objc func credits() {
        
        let ac = UIAlertController(title: "All data downloaded from:", message: "www.whitehouse.gov", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        
    }
    
    @objc func showError() {
                let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
        
    }
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}



