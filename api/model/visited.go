package model

import "time"

type Visited struct {
	ID        int       `gorm:"primaryKey" json:"id"`
	SpotID    int       `gorm:"not null" json:"spot_id"`
	UserID    int       `gorm:"not null" json:"user_id"`
	CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at"`

	// Relations
	Spot *Spots `gorm:"foreignKey:SpotID" json:"spot,omitempty"`
	User *Users `gorm:"foreignKey:UserID" json:"user,omitempty"`
}
