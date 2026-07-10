import UIKit

// MARK: - FriendTableDataSource
//
// Separates UITableViewDataSource from the ViewController

final class FriendTableDataSource: NSObject, UITableViewDataSource {

    // MARK: - Private state
    private var friends: [FriendCellViewModel] = []

    // MARK: - Update
    func update(friends: [FriendCellViewModel]) {
        self.friends = friends
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FriendCell.reuseIdentifier,
            for: indexPath
        ) as! FriendCell
        cell.configure(with: friends[indexPath.row])
        return cell
    }
}
