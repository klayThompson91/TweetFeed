//
//  LoginViewController.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/15/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

// Adhere to this delegate protocol to get updated when LoginViewController successfully authenticates the user.
public protocol LoginViewControllerDelegate: class
{
    func loginViewControllerAuthenticatedUser()
}

// LoginViewController is the login page for the TweetFeed App.
// Manages the authentication UX and drives the authentication flow.
public class LoginViewController: UIViewController, AuthenticationManagerDelegate, SFSafariViewControllerDelegate {
    
    public weak var delegate: LoginViewControllerDelegate?
    
    private let authenticationManager = AuthenticationManager()
    
    private let authStatusMessageLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.regular)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 36, weight: UIFont.Weight.semibold)
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    private let twitterImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = TweetFeedImages.twitterLogo
        return imageView
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.white, for: .disabled)
        return button
    }()
    
    private let kAppName = "TweetFeed"
    private let kLoginButtonText = "Log In"
    private let kLoginMessage = "View your tweets and follow your friends!"
    private let kAuthenticationMessage = "Authenticating.."
    private let kWelcomeMessage = "Welcome, "
    private let kAuthenticationFailureTitle = "Authentication Failed"
    private let kAuthenticationFailureMessage = "Failed to authenticate with Twitter, please check your username and password and try logging in again."
    private let kOkButtonText = "OK"
    private let kAnimationDuration = 0.25
    
    // MARK: - View Creation and Layout
    override public func viewDidLoad() {
        authenticationManager.delegate = self
        view.backgroundColor = TweetFeedStyle.themeColor
        loginButton.setTitle(kLoginButtonText, for: .normal)
        loginButton.setTitle(kLoginButtonText, for: .disabled)
        loginButton.addTarget(self, action: #selector(loginButtonPressed(_:)), for: .touchUpInside)
        authStatusMessageLabel.text = kLoginMessage
        headerLabel.text = kAppName
        view.addSubviews([loginButton, authStatusMessageLabel, headerLabel, twitterImageView])
        setupConstraints()
    }

    public func resetSession() {
        TweetFeedUserCredentials().clearAppCredentials()
        animateAndUpdateAuthStatusMessageLabel(statusMessage: kLoginMessage) { (finishedAnimating) in
            self.fadeInLoginButton(completion: nil)
        }
    }
    
    // MARK: - SFSafariViewControllerDelegate
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        authenticationManager.cancel()
        animateAndUpdateAuthStatusMessageLabel(statusMessage: kLoginMessage) { (finishedAnimating) in
            if finishedAnimating {
                self.fadeInLoginButton(completion: nil)
            }
        }
    }
    
    // MARK: - AuthenticationManagerDelegate
    public func launchBrowser(authenticationUrl: URL) {
        let safariViewController = SFSafariViewController(url: authenticationUrl)
        safariViewController.modalPresentationStyle = .overFullScreen
        safariViewController.delegate = self
        present(safariViewController, animated: true, completion: nil)
    }
    
    public func dismissBrowser() {
        dismiss(animated: true, completion: nil)
    }
    
    public func authenticationDidSucceed() {
        animateAndUpdateAuthStatusMessageLabel(statusMessage: "\(kWelcomeMessage)\(TweetFeedUserCredentials.twitterHandle) !") { (finishedAnimating) in
            if finishedAnimating {
                self.delegate?.loginViewControllerAuthenticatedUser()
            }
        }
    }
    
    public func authenticationFailed() {
        let alert = UIAlertController(title: kAuthenticationFailureTitle, message: kAuthenticationFailureMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(kOkButtonText, comment: ""), style: .default, handler: { _ in
            self.animateAndUpdateAuthStatusMessageLabel(statusMessage: self.kLoginMessage) { (finishedAnimating) in
                if finishedAnimating {
                    self.fadeInLoginButton(completion: nil)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Private Helpers
    private func setupConstraints() {
        UIView.disableAutoresize(forViews: [loginButton, authStatusMessageLabel, headerLabel, twitterImageView])
        let viewConstraints = [
            twitterImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            twitterImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 55),
            headerLabel.topAnchor.constraint(equalTo: twitterImageView.bottomAnchor),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authStatusMessageLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 35),
            authStatusMessageLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -35),
            authStatusMessageLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 130),
            loginButton.topAnchor.constraint(lessThanOrEqualTo: authStatusMessageLabel.bottomAnchor, constant: 170),
            loginButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -35),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        NSLayoutConstraint.activate(viewConstraints)
    }
    
    @objc private func loginButtonPressed(_ sender: UIButton) {
        fadeOutLogInButton { (finishedAnimating) in
            if finishedAnimating {
                self.animateAndUpdateAuthStatusMessageLabel(statusMessage: self.kAuthenticationMessage, completion: { (finishedAnimating) in
                    if finishedAnimating {
                        self.authenticationManager.authenticate()
                    }
                })
            }
        }
    }
    
    private func fadeInLoginButton(completion: ((Bool) -> Void)?)
    {
        UIView.animate(withDuration: kAnimationDuration, animations: {
            self.loginButton.alpha = 1.0
        }, completion: completion)
    }
    
    private func fadeOutLogInButton(completion: ((Bool) -> Void)?)
    {
        UIView.animate(withDuration: kAnimationDuration, animations: {
            self.loginButton.alpha = 0.0
        }, completion: completion)
    }
    
    private func animateAndUpdateAuthStatusMessageLabel(statusMessage: String, completion: ((Bool) -> Void)?)
    {
        UIView.transition(with: authStatusMessageLabel, duration: kAnimationDuration, options: [.transitionCrossDissolve], animations: {
            self.authStatusMessageLabel.text = statusMessage
        }, completion: completion)
    }
    
}
