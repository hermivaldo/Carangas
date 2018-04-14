//
//  AddEditViewController.swift
//  Carangas
//
//  Created by Eric Brito.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit

class AddEditViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tfBrand: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var scGasType: UISegmentedControl!
    @IBOutlet weak var btAddEdit: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!

    
    var pickerView: UIPickerView!
    var dataSource:[Fipe] = []
    
    var car: Car!
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if car != nil {
            tfName.text = car.name
            tfBrand.text = car.brand
            tfPrice.text = "\(car.price)"
            scGasType.selectedSegmentIndex = car.gasType
            btAddEdit.setTitle("Alterar", for: .normal)
        }
        
        pickerView = UIPickerView()
        
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        
        //O botão abaixo servirá para o usuário cancelar a escolha de gênero, chamando o método cancel
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        //O botão done confirmará a escolha do usuário, chamando o método done.
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
    
        tfBrand.inputView = pickerView
        tfBrand.inputAccessoryView = toolbar
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        REST.loadBrand(onComplete: { (fipes) in
            self.dataSource = fipes
            
            DispatchQueue.main.async {
                self.pickerView.reloadAllComponents()
                
                let linha = self.dataSource.index(where: { (fipe) -> Bool in
                    fipe.name.elementsEqual(self.tfBrand.text!)
                })!
                self.pickerView.selectRow(linha, inComponent: 0, animated: false)
            }
        }) { (status) in
            print(status)
        }
    }
    
    @objc func cancel() {
       
        tfBrand.resignFirstResponder()
    }
    
    //O método done irá atribuir ao textField a escolhe feita no pickerView
    @objc func done() {
        
        
        tfBrand.text = dataSource[pickerView.selectedRow(inComponent: 0)].name

        cancel()
    }
    
    // MARK: - IBActions
    @IBAction func addEdit(_ sender: UIButton) {
        
        sender.isEnabled = false
        sender.alpha = 0.5
        sender.backgroundColor = .gray
        
        if car == nil {
            car = Car()
        }
        
        car.brand = tfBrand.text!
        car.name = tfName.text!
        car.gasType = scGasType.selectedSegmentIndex
        car.price = Double(tfPrice.text!)!
        
        if car._id == nil {
            REST.saveCar(car, onComplete: { (success) in
                self.goBack()
            })
        }else {
            REST.updateCar(car, onComplete: { (success) in
                self.goBack();
            })
        }
    }

    func goBack(){
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension AddEditViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //Retornando o texto recuperado do objeto dataSource, baseado na linha selecionada
        return dataSource[row].name
    }
}

extension AddEditViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1    //Usaremos apenas 1 coluna (component) em nosso pickerView
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        return dataSource.count //O total de linhas será o total de itens em nosso dataSource
    }
}
