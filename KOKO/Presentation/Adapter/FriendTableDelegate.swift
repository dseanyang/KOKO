import UIKit

// MARK: - FriendTableDelegate
//
// Separates UITableViewDelegate from the ViewController

final class FriendTableDelegate: NSObject, UITableViewDelegate {

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        FriendCell.rowHeight
    }
    
    // Future additions like didSelectRowAt can go here
}
