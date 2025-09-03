package model

type Likes struct {
	ID     int `gorm:"primaryKey" json:"id"`
	SpotID int `gorm:"not null" json:"spot_id"`
	UserID int `gorm:"not null" json:"user_id"`
}