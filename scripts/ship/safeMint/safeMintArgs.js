//safeMint(address to, Metadata memory md)
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
module.exports = {
    mintTO: '0x1f77fbb2fa9487a7ddde210ae4666a73dcd8b2a3',
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
    getMetadata:function (md){
        return [md.image,md.animation_url,md.attr_name,md.attr_type,md.attr_rank,
        md.attr_hull,md.attr_energy,md.attr_speed,
            md.attr_fight,md.attr_exploration,md.attr_harvest];
    }
}