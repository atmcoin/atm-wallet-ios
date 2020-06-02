
import UIKit
import MapKit
import WacSDK

private let kAtmAnnotationViewReusableIdentifier = "kAtmAnnotationViewReusableIdentifier"

class WACWithdrawalStatusViewController: WACActionViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var atmMapView: MKMapView!
    @IBOutlet weak var atmLocationDescription: UILabel!
    @IBOutlet weak var amountUSDLabel: UILabel!
    @IBOutlet weak var amountBTCLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var redeemCodeLabel: UILabel!
    
    private var timer = Timer()
    
    var transaction: WACTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cashCodeStatus(self)
        self.timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { timer in
            self.cashCodeStatus(self)
        }
        
        initialData()
    }
    
    deinit {
        self.timer.invalidate()
    }
    
    func initialData() {
        atmMapView.register(AtmAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        atmMapView.delegate = self
        
        if let atm = transaction.atm, let latitude = atm.latitude,
            let longitude = atm.longitude {
            let atmLocation = CLLocation(latitude: (latitude as NSString).doubleValue, longitude: (longitude as NSString).doubleValue)
            atmMapView.centerToLocation(atmLocation)
            self.atmLocationDescription.text = transaction.atm?.addressDesc
        }
        
        if let code = transaction.code {
            let btcAmount = (code.btcAmount! as NSString).doubleValue
            let usdAmount = (code.usdAmount! as NSString).doubleValue
            
            setQRCode(from:code.address!, amount:btcAmount)
        
            self.amountUSDLabel.text = "$\(usdAmount)"
            self.amountBTCLabel.text = "\(btcAmount) BTC"
            self.addressLabel.text = code.address
        }
    }
    
    @IBAction func cashCodeStatus(_ sender: Any) {
        WACSessionManager.shared.client?.checkCashCodeStatus((transaction.code?.secureCode)!, completion: { (response: WacSDK.CashCodeStatusResponse) in
            let cashCode = (response.data?.items.first)! as CashStatus
            if let code = cashCode.code {
                self.redeemCodeLabel.text = code
            }
            let codeStatus = cashCode.getCodeStatus()!
            let transactionStatus = WACTransactionStatus.transactionStatus(from: codeStatus)
            WACTransactionManager.shared.updateTransaction(status: transactionStatus, forAddress: cashCode.address!)
            self.setStatusView(codeStatus)
//            self.navigationBar.topItem?.title = cashCode.status
        })
    }
    
    func setStatusView(_ status: CodeStatus) {
        self.qrCodeImageView.isHidden = true
        self.redeemCodeLabel.isHidden = true
        switch status {
        case .AWAITING:
            self.qrCodeImageView.isHidden = false
            break
        case .FUNDED_NOT_CONFIRMED:
            self.redeemCodeLabel.isHidden = false
            self.redeemCodeLabel.text = "PROCESSING"
            break
        case .FUNDED:
            self.redeemCodeLabel.isHidden = false
            break
        case .USED:
            break
        case .CANCELLED:
            break
        }
    }
    
    private func setQRCode(from address: String, amount btc: Double) {
        let finalAddress = "bitcoin:\(address)?amount=\(btc)"
        guard let data = finalAddress.data(using: .utf8) else { return }
        self.qrCodeImageView.image = UIImage
            .qrCode(data: data)!
            .resize(self.qrCodeImageView.frame.size)
    }
    
    private func setMapLocation(coordinates coord: CLLocationCoordinate2D) {
        let annotation = AtmAnnotation.init(atm: transaction.atm!)
        self.atmMapView.addAnnotation(annotation)
    }
    
    @objc override public func hideView() {
        super.hideView()
        self.dismiss(animated: true, completion: nil)
    }
}

extension WACWithdrawalStatusViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if annotation is MKUserLocation { return nil }
            
            var annotationView = atmMapView.dequeueReusableAnnotationView(withIdentifier: kAtmAnnotationViewReusableIdentifier)
            
            if annotationView == nil {
                annotationView = AtmAnnotationView(annotation: annotation, reuseIdentifier: kAtmAnnotationViewReusableIdentifier)
            } else {
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
}
