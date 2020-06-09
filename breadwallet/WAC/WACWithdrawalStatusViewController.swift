
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
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var redeemCodeLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    var transaction: WACTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialData()
        setMapLocation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(transactionDidUpdate), name: .WACTransactionDidUpdate, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    private func update() {
        if let code = transaction.pCode {
            self.redeemCodeLabel.text = code
        }
        self.updateStatus(transaction.status)
    }
    
    func updateStatus(_ status: WACTransactionStatus) {
        self.qrCodeImageView.isHidden = true
        self.redeemCodeLabel.isHidden = false
        self.addressLabel.isHidden = true
        self.addressTitleLabel.isHidden = true
        self.sendButton.isHidden = true
        switch status {
        case .Awaiting, .FundedNotConfirmed:
            // To the server there is no difference
            self.addressLabel.isHidden = false
            self.addressTitleLabel.isHidden = false
            self.redeemCodeLabel.text = "PROCESSING"
            break
        case .Funded:
            // Show Code to redeem
            break
        case .Withdrawn:
            self.redeemCodeLabel.text = "WITHDRAWN"
            break
        case .Cancelled:
            self.redeemCodeLabel.text = "CANCELLED"
            break
        case .VerifyPending:
            break
        case .SendPending:
            self.qrCodeImageView.isHidden = false
            self.redeemCodeLabel.isHidden = true
            self.addressLabel.isHidden = false
            self.addressTitleLabel.isHidden = false
            self.sendButton.isHidden = false
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
    
    private func setMapLocation() {
        let annotation = AtmAnnotation.init(atm: transaction.atm!)
        self.atmMapView.addAnnotation(annotation)
    }
    
    @objc override public func hideView() {
        super.hideView()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func transactionDidUpdate(_ notification: Notification) {
        let t = notification.object as! WACTransaction
        if (t == self.transaction) {
            update()
        }
    }
    
    @IBAction func sendCoin(_ sender: Any) {
        WACAtmLocationsViewController.sendCoin(amount: (transaction.code?.btcAmount)!, address: (transaction.code?.address)!, completion: {
            WACTransactionManager.shared.updateTransaction(status: .Awaiting, address: (self.transaction.code?.address)!)
            self.update()
        })
    }
}

extension WACWithdrawalStatusViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if annotation is MKUserLocation { return nil }
            
            var annotationView = atmMapView.dequeueReusableAnnotationView(withIdentifier: kAtmAnnotationViewReusableIdentifier)
            
            if annotationView == nil {
                annotationView = AtmAnnotationView(annotation: annotation, reuseIdentifier: kAtmAnnotationViewReusableIdentifier)
                annotationView?.image = UIImage(named: "atmBlack")
            } else {
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
}
