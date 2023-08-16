
//function newBatch(uint256 saleStartTime,uint256 roundTime,uint256 saleQuantity,uint256 startingPrice,uint256 incrementPrice,uint256 purchaseLimit,
// AstraOmniRiseSpaceship.Metadata memory metadata)
//struct Metadata {
//         string image;
//         string animation_url;
//         string attr_name;
//         string attr_type;
//         string attr_rank;
//         uint256 attr_hull;
//         uint256 attr_energy;
//         uint256 attr_speed;
//
//
//         uint256 attr_fight;
//         uint256 attr_exploration;
//         uint256 attr_harvest;
//     }
let decimals = Math.pow(10,18).toString().substring(1);
module.exports = {
    saleStartTime: 1686036600,
    roundTime: 30*60,
    saleQuantity: 15,
    startingPrice: "100" + decimals,
    incrementPrice: "100" + decimals,
    purchaseLimit: 5,
    metadata:{
        image:"QmPAkeXAQeYREG4tnujvVqHiVtwAqAQzB7aUyQ3tAZfvgz",
        animation_url:"QmcRYioD9353vV49E8WDeiqdGnuATz6TLxQoHRRBs6CQEZ",
        attr_name:"Firefly",
        attr_type:"Fighter",
        attr_rank:"D",
        attr_hull:"200",
        attr_energy:"30",
        attr_speed:"120",

        attr_fight:"45",
        attr_exploration:"0",
        attr_harvest:"0"
    },
    /*metadata:{
        image:"QmP7KeCJPpdhu7fagYrQrkemKtrtTCrV274PDprS6kiYpA",
        animation_url:"QmWg2May3fmm2xLVW1xcBomd8T3jXw9mhzFrTCJkcxrTb4",
        attr_name:"Infinity",
        attr_type:"Explorer",
        attr_rank:"A",
        attr_hull:"32000",
        attr_energy:"80",
        attr_speed:"90",

        attr_fight:"0",
        attr_exploration:"3750",
        attr_harvest:"0"
    },*/
    getMetadata:function (){
        let md = this.metadata;
        return [md.image,md.animation_url,md.attr_name,md.attr_type,md.attr_rank,
        md.attr_hull,md.attr_energy,md.attr_speed,
            md.attr_fight,md.attr_exploration,md.attr_harvest];
    }
}