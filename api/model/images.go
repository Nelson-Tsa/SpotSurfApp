package model

type Images struct {
	ID     int    `gorm:"primaryKey" json:"id"`
	Image  []byte `gorm:"type:bytea;not null" json:"image_data"`
	SpotID int    `gorm:"not null" json:"spot_id"`

	// Relation
	Spot *Spots `gorm:"foreignKey:SpotID" json:"spot,omitempty"`
}
