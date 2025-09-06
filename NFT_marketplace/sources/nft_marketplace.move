module ws_sui::nft_marketplace {
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::sui::SUI;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::option::{Option}; 

    const EWrongPrice: u64 = 1;
    const ENotSeller: u64 = 3;

    public struct Listing<T: key + store> has key, store {
        id: UID,
        seller: address,
        price_in_sui: u64,
        object: Option<T>
    }

    public fun list<T: key + store>(
        nft: T,
        price: u64,
        ctx: &mut TxContext
    ) {
        let seller_addr = tx_context::sender(ctx);

        let listing = Listing {
            id: object::new(ctx),
            seller: seller_addr,
            price_in_sui: price,
            object: std::option::some(nft) 
        };

        transfer::share_object(listing);
    }

    public fun buy<T: key + store>(
        listing: &mut Listing<T>,
        payment: Coin<SUI>,
        ctx: &mut TxContext
    ): T {
        assert!(coin::value(&payment) == listing.price_in_sui, EWrongPrice);

        transfer::public_transfer(payment, listing.seller);

        let nft = std::option::extract(&mut listing.object);
        nft
    }

    public fun delist<T: key + store>(
        listing: &mut Listing<T>, 
        ctx: &mut TxContext
    ): T {
        let caller = tx_context::sender(ctx);
        assert!(listing.seller == caller, ENotSeller);
        let nft = std::option::extract(&mut listing.object);

        nft
    }
}