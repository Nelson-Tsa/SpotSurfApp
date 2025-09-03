package model

type Likes struct {
	ID     int `gorm:"primaryKey" json:"id"`
	SpotID int `gorm:"not null" json:"spot_id"`
	UserID int `gorm:"not null" json:"user_id"`
}

type Visited struct {
	ID        int    `gorm:"primaryKey" json:"id"`
	SpotID    int    `gorm:"not null" json:"spot_id"`
	UserID    int    `gorm:"not null" json:"user_id"`
	CreatedAt string `gorm:"not null" json:"created_at"`
}
