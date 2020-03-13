import Foundation
import CommonCrypto
import UIKit
import CryptoSwift
import WebKit;


class ViewController: UIViewController,WKNavigationDelegate
{
    let key = "ccC2H19lDDbQDfakxcrtNMQdd0FloLGG" // length == 32
    let iv = "ggGGHUiDD0Qjhuvv" // length == 16
    enum AESError: Error {
        case KeyError((String, Int))
        case IVError((String, Int))
        case CryptorError((String, Int))
    }
    @IBOutlet weak var mWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let preferences = WKPreferences()
        mWebView.navigationDelegate = self
        preferences.javaScriptEnabled = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddhhmmss"
        let merchant_id = "E01100000000009"
        let value = "1"
        let currency = "INR"
        let mode = "live"
        let time: String = dateFormatter.string(from: currentDate)
        let merid_time = merchant_id + time
        let AA = "AA"
        let Pg = "Pg"
        let url_data = "https://paymentgateway.test.credopay.in/shop/checkout.php?"
        let encdata = merchant_id + value + currency + mode + time + merid_time + AA + Pg + url_data
        
        // print(encdata)
        //print("encdataa")
        
        
        //   let sha256Str = sha256(str: str);
        // print(sha256Str);
        
        
        
        do {
            let aes = try AES(key: "524d52fce6c1e82fa19e8e32e0fc0459", iv: "ffd3877141b16876") // aes128
            let ciphertext = try aes.encrypt(Array(encdata.bytes))
            var dataa = ciphertext.toBase64()
            print("======encdata======")
            print(dataa)
            print("============")
            let escapedString = dataa!.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
            print(escapedString)
            var originalString = escapedString
            var customAllowedSet =  NSCharacterSet(charactersIn:"=\"#%/<>?@\\^`{|}+").inverted
            let finaldata = originalString!.addingPercentEncoding(withAllowedCharacters:customAllowedSet)
            print(finaldata)
            print("finaldata")

            //=======================cardpayment
            let postData =
                "&merchant_id=" + "E01100000000009"
                    + "&amount=" + "1"
                    + "&currency=" + "INR"
                    + "&env=" + "live"
                    + "&timestamp=" + time
                    + "&Transaction_id=" + merid_time
                    + "&TransactionType=" + "AA"
                    + "&PaymentChannel=" + "Pg"
                    + "&redirectionurl=" + "https://paymentgateway.test.credopay.in/shop/checkout.php?"
                    + "&encData=" + finaldata!;
            var request = URLRequest(url: URL(string: "https://pg.credopay.net/payform_scratch_thiyagu.php")!)
            request.httpMethod = "POST"
            let params = postData
            request.httpBody = params.data(using: .utf8)
            mWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
            let task = URLSession.shared.dataTask(with: request) { (data : Data?, response : URLResponse?, error : Error?) in
                if data != nil
                {
                    if let returnString = String(data: data!, encoding: .utf8)
                    {
                        self.mWebView.loadHTMLString(returnString, baseURL: URL(string: "https://pg.credopay.net/payform_scratch_thiyagu.php")!)
                    }
                }
            }
            task.resume()
            
            
            
            //=========================cardpayment
            
            
            
            //
            //        let postt =   "&merchant_id=" + merchant_id
            //                                     + "&amount=" + "1"
            //                                     + "&currency=" + "INR"
            //                                     + "&env=" + "live"
            //                                     + "&timestamp=" + time
            //                                     + "&Transaction_id=" + merchant_id + time
            //                                     + "&TransactionType=" + "AA"
            //                                     + "&PaymentChannel=" + "Pg"
            //                                     + "&redirectionurl=" + "https://paymentgateway.test.credopay.in/shop/checkout.php?"
            //                                     + "&buyerEmail=" + "buyer@example.com"
            //                                     + "&buyerPhone=" + "9874563210"
            //                                     + "&orderid=" + merchant_id + time
            //                                     + "&buyerFirstName=" + "SampleFirst"
            //                                     + "&buyerLastName=" + "SampleFirst"
            //                                     + "&WIDout_trade_no=" + "test20200206162831"
            //                                     + "&WIDsubject=" + "test123"
            //                                     + "&WIDtotal_fee=" + "1"
            //                                     + "&WIDbody=" + "test"
            //                                     + "&WIDproduct_code=" + "NEW_OVERSEAS_SELLER"
            //                                     + "&tran_req_type=" + "cb1"
            //                                     + "&payment_method=" + "smartro"
            //                                     + "&ponumber=" + time;
            
            
            
            
        }
        catch {
            
        }
        
    }
    func webView(_ webView: WKWebView,didFinish navigation: WKNavigation!) {
        let url = webView.url
        let value = url?.absoluteString
        
        if((value?.contains("https://pg.credopay.net/resp.php"))!)
        {
            
            if((value?.contains("success=false"))!)
            {
             
                let alert = UIAlertController(title: "Failed!", message: "Transaction Failed", preferredStyle: .alert)

     alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    print("Failed Transaction")
                }))

                self.present(alert, animated: true)
            }
            
            
            if((value?.contains("success=true"))!)
            {
           let alert = UIAlertController(title: "Success!", message: "Transaction Success", preferredStyle: .alert)

             alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                            print("Transaction done!")
                        }))

                        self.present(alert, animated: true)
            
            }
            
        }
      
        print(value)
        
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == "estimatedProgress" {
            print(Float(mWebView.estimatedProgress))
        }
    }
    
    
    
    
    
}

func encodeValue(_ string: String) -> String? {
    guard let unescapedString = string.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: ":/").inverted) else { return nil }
    
    return unescapedString
}

func sha256(str: String) -> String {
    
    if let strData = str.data(using: String.Encoding.utf8) {
        /// #define CC_SHA256_DIGEST_LENGTH     32
        /// Creates an array of unsigned 8 bit integers that contains 32 zeros
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
        
        /// CC_SHA256 performs digest calculation and places the result in the caller-supplied buffer for digest (md)
        /// Takes the strData referenced value (const unsigned char *d) and hashes it into a reference to the digest parameter.
        strData.withUnsafeBytes {
            // CommonCrypto
            // extern unsigned char *CC_SHA256(const void *data, CC_LONG len, unsigned char *md)  -|
            // OpenSSL                                                                             |
            // unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md)        <-|
            CC_SHA256($0.baseAddress, UInt32(strData.count), &digest)
        }
        
        var sha256String = ""
        /// Unpack each byte in the digest array and add them to the sha256String
        for byte in digest {
            sha256String += String(format:"%02x", UInt8(byte))
        }
        
        if sha256String.uppercased() == "E8721A6EBEA3B23768D943D075035C7819662B581E487456FDB1A7129C769188" {
            print("Matching sha256 hash: E8721A6EBEA3B23768D943D075035C7819662B581E487456FDB1A7129C769188")
        } else {
            print("sha256 hash does not match: \(sha256String)")
        }
        return sha256String
    }
    return ""
}


