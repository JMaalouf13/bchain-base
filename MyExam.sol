// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

//Entre ChatGPTed et Documentation https://docs.openzeppelin.com/contracts/4.x/api/token/erc721

contract NFTexam is  ERC721, AccessControl, Pausable{

    string private _name = "NFTexam";
    string private _symbol = "Zer"; //Pour Zero, bien sûr

    uint256 public constant TOTAL_SUPPLY = 5;
    uint256 public constant VIP_PRICE = 1 ether;
    uint256 public constant BASE_PRICE = 2 ether;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VIP_ROLE = keccak256("VIP_ROLE");
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");
    
    constructor() ERC721(_name, _symbol) {
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(VIP_ROLE, msg.sender);
    }

/*   function totalSupply() public view returns (uint256) {
        return balanceOf[address(this)] + balanceOf[msg.sender];
}*/
    
    //Gestion de l'intersection de fonctions
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mint(address to, uint256 tokenId) public payable whenNotPaused {
        // Vérifier que le nombre total de NFTs n'a pas été atteint
        //require(totalSupply() < TOTAL_SUPPLY, "Supply max atteinte");
        
        require(!_exists(tokenId), "TokenID existe deja");

        if (hasRole(ADMIN_ROLE, msg.sender)) {
            // L'administrateur peut acheter un NFT gratuitement
            _mint(to, tokenId);
        } else if (hasRole(VIP_ROLE, msg.sender)) {
            // Le VIP peut acheter un NFT avec un prix avantageux
            require(msg.value >= VIP_PRICE, "Le prix est inferieur au prix VIP");
            _mint(to, tokenId);
        } else if (hasRole(WHITELIST_ROLE, msg.sender)) {
            // Le membre de la Whitelist peut acheter un NFT avec le prix de base
            require(msg.value >= BASE_PRICE, "Le prix est inferieur au prix de base");
            _mint(to, tokenId);
        } else {
            // Sinon, l'achat est refusé
            revert("Vous n'etes pas autorise a acheter un NFT");
        }
    }
    
    function pause() public onlyRole(ADMIN_ROLE) {
        _pause();
    }
    
    function unpause() public onlyRole(ADMIN_ROLE) {
        _unpause();
    }
    
    function ban(address account) public onlyRole(ADMIN_ROLE) {
        revokeRole(ADMIN_ROLE, account);
        revokeRole(VIP_ROLE, account);
        revokeRole(WHITELIST_ROLE, account);
    }
    
    function addVIP(address account) public onlyRole(ADMIN_ROLE) {
        grantRole(VIP_ROLE, account);
    }
    
    function addWhitelist(address account) public onlyRole(ADMIN_ROLE) {
        grantRole(WHITELIST_ROLE, account);
    }
}
