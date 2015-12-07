import UIKit
import Cache

class ViewController: UIViewController {

  lazy var label: UILabel = {
    let label = UILabel()
    label.text = NSLocalizedString("It's not really a demo, open playgrounds instead 👽", comment: "")
    label.numberOfLines = 0
    label.textAlignment = .Center

    return label
    }()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .whiteColor()
    view.addSubview(label)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    label.frame.size.width = 300
    label.sizeToFit()
    label.center = CGPoint(x: view.center.x, y: view.center.y - 100)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}

