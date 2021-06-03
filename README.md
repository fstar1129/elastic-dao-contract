# ElasticDAO Contracts 

Elastic DAO is a governance protocol that attempts to balance the competing interests between the different participants in a decentralized ecosystem. Elastic DAO achieves this by reducing the overall influence that money and early adopters have in existing DAO governance models.

ElasticDAO relies on Snapshot for it's voting approach (due to gas prices) pending implementation with a
layer 2 solution after launch. For this reason, most functions which would be performed by voting are
actually executed by a multisig. This multisig will be the owner of the proxy contracts, the ElasticDAO
controller, the burner, and the minter.
