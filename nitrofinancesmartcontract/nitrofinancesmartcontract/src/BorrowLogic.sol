pragma solidity 0.8.7;

contract BorrowLogic{
    
    
    struct BORROWTRANSACTIONS{
        uint256 interestRateBorrowedAt;
        uint256 collateralFactorBorrowedAt;
        uint256 totalBorrowed;
        address borrower;
        uint locusId;
        
       
    }

    struct LIQUIDATEDTRANSACTIONS{
        uint256 locusId;
        uint256 interestRateBorrowedAt;
        uint256 collateralFactorBorrowedAt;
        uint amountLiquidatedFromPool;
    }

    mapping (address=>BORROWTRANSACTIONS[]) public addressToBorrowTransaction;
    LIQUIDATEDTRANSACTIONS []liquidatedTransactions;
    address [] allLiquidators;
}