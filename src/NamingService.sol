// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

contract NamingService {

    uint pricePerDigit = 0.001 ether;
    uint public totalNameClaims;

    mapping(address => uint) addressDomainCount;
    mapping(string => bool) nameTaken;
    mapping(string => address) domainOwner;
    mapping(string => Domain) domains;

    // mapping(string => mapping(address => uint256)) offers;
    mapping(string => Offer[]) allOffers;
    mapping(string => mapping(address => Offer)) offerFromAddress;


    enum DomainState {
        listed,
        notListed
    }

    enum OfferState {
        active,
        cancelled
    }

    struct Domain {
        address payable owner;
        string name;
        uint salePrice;
        DomainState domainState;
    }

    struct Offer {
        string domainName;
        address sender;
        uint256 amountOffered; 
        OfferState offerState;
    }

    event NameRegistered(address owner, string name);
    event OwnershipTransfered(string name, address newOwner, address previousOwner);

    modifier isNameOwner(string memory _name, address user){
        require(domainOwner[_name] == user, "You are not this name's owner");
        _;
    }

    constructor() {
        totalNameClaims = 0;
    }

    function registerDomainName(string memory _name) public payable {
        require(nameTaken[_name] != true, "Name has been claimed");
        uint registrationCost = (bytes(_name).length) * pricePerDigit;
        require(msg.value >= registrationCost, "Not enough ETH sent");
        
        nameTaken[_name] = true;
        domains[_name].owner = payable(msg.sender);
        domains[_name].name = _name;
        domains[_name].domainState = DomainState.notListed;
        domains[_name].salePrice = 0 ether;
        addressDomainCount[msg.sender] ++;
        domainOwner[_name] = msg.sender;
        totalNameClaims ++;

        emit NameRegistered(msg.sender, _name);
    }

    function transferOwnership(string memory _domainName, address _reciever) public {
        require(nameTaken[_domainName] == true && domains[_domainName].owner == msg.sender, "You do not own this domain Name");

        //make reciever new owner
        domains[_domainName].owner = payable(_reciever);
        domainOwner[_domainName] = _reciever;
        addressDomainCount[msg.sender]--;
        addressDomainCount[_reciever]++;

        emit OwnershipTransfered(_domainName, _reciever, msg.sender);
    }

    function makeNameAvailableForSale(string memory _domainName, uint256 listingPrice) public {
        require(nameTaken[_domainName] == true && domains[_domainName].owner == msg.sender, "You do not own this domain Name");
        require(domains[_domainName].domainState == DomainState.notListed, "Domain already listed for sale");

        domains[_domainName].domainState = DomainState.listed;
        domains[_domainName].salePrice = listingPrice;
    }

    function purchaseDomain(string memory _domainName) public payable {
        Domain memory domain = domains[_domainName];
        
        require(domain.domainState == DomainState.listed, "Domain NOT listed for sale");
        require(msg.value >= domain.salePrice, "Not enough ETH sent");

        addressDomainCount[msg.sender]++;
        addressDomainCount[domain.owner]--;
        domain.domainState = DomainState.notListed;

        domains[domain.name].owner = payable(msg.sender);
        domainOwner[domain.name] = msg.sender;
        domain.owner.transfer(msg.value);
    }

    function viewDomainOwner(string memory _domainName) public view returns(address) {
        return domains[_domainName].owner;
    }

    function addOffer ( string memory _domainName) public payable {
        require(msg.sender != domainOwner[_domainName], "You can't make yourself an offer");

        Offer memory offer = Offer({
            domainName : _domainName,
            sender : msg.sender,
            amountOffered : msg.value,
            offerState : OfferState.active
        });

        offerFromAddress[_domainName][msg.sender] = offer;
        allOffers[_domainName].push(offer);
    }

    function cancelOffer( string memory _domainName ) public payable {
        uint256 refund = offerFromAddress[_domainName][msg.sender].amountOffered;
        offerFromAddress[_domainName][msg.sender].offerState = OfferState.cancelled;
        payable(msg.sender).transfer(refund);
    }

    function viewAddressOffer (string memory _domainName) public view returns (Offer memory) {
        return offerFromAddress[_domainName][msg.sender];  
    }

    function viewDomainOffers(string memory _domainName) public view returns (Offer[] memory) {
        return allOffers[_domainName];
    }

    function acceptOffer(string memory _domainName, address _reciever ) public {
        require(msg.sender != _reciever, "Accept Offer: NO");
        require(domainOwner[_domainName] == msg.sender, "Accept Offer: You do not own this domain");
        
        payable(msg.sender).transfer(offerFromAddress[_domainName][_reciever].amountOffered);
        
        Domain memory domain = domains[_domainName];

        addressDomainCount[msg.sender]--;
        addressDomainCount[_reciever]++;
        domain.domainState = DomainState.notListed;
        domain.salePrice = 0;

        domains[domain.name].owner = payable(_reciever);
        domainOwner[domain.name] = _reciever;
    }
    
}