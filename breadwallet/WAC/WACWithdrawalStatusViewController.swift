
import UIKit
import MapKit
import WacSDK

class WACWithdrawalStatusViewController: UIViewController {
    
    @IBOutlet weak var atmMapView: MKMapView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var atmLocationDescription: UILabel!
    @IBOutlet weak var amountUSDLabel: UILabel!
    @IBOutlet weak var amountBTCLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    private var _transaction: WACTransaction!
    var transaction: WACTransaction {
        set {
            _transaction = newValue
            setQRCode(from: _transaction.address!, amount: _transaction.amountBTC!)
//            if let latitude = Double(_transaction.atm?.latitude),
//                let longitude = Double(_transaction.atm?.longitude) {
//                setMapLocation(coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
//            }
            self.atmLocationDescription.text = _transaction.atm?.addressDesc
            self.amountUSDLabel.text = "\(String(describing: _transaction.amountUSD))"
            self.amountBTCLabel.text = "\(String(describing: _transaction.amountBTC))"
        }
        get {
            return _transaction
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    private func setQRCode(from address: String, amount btc: Double) {
        let finalAddress = "bitcoin:\(address)?amount=\(btc)"
        guard let data = finalAddress.data(using: .utf8) else { return }
        self.qrCodeImageView.image = UIImage.qrCode(data: data)
    }
    
    private func setMapLocation(coordinates coord: CLLocationCoordinate2D) {
//        self.atmMapView.addAnnotation(<#T##annotation: MKAnnotation##MKAnnotation#>)
    }
}

extension WACWithdrawalStatusViewController: MKMapViewDelegate {
    
}
