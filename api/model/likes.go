package model

type Likes struct {
	ID     int64 `gorm:"primaryKey" json:"id"`
	SpotID int64 `gorm:"not null" json:"spot_id"`
	UserID int64 `gorm:"not null" json:"user_id"`

	// Relations
	Spot *Spots `gorm:"foreignKey:SpotID" json:"spot,omitempty"`
	User *Users `gorm:"foreignKey:UserID" json:"user,omitempty"`
}
