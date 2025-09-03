package model

type Spots struct {
	ID          int    `gorm:"primaryKey" json:"id"`
	City        string `gorm:"not null" json:"city"`
	Name        string `gorm:"not null" json:"name"`
	Description string `gorm:"not null" json:"description"`
	Level       string `gorm:"not null" json:"level"`
	Difficulty  string `gorm:"not null" json:"difficulty"`
	Gps         string `gorm:"not null" json:"gps"`
	Image       []byte `gorm:"type:bytea;not null" json:"image"`
	UserID      int    `gorm:"not null" json:"user_id"`
	LikeCount   int    `gorm:"not null" json:"like_count"`

	User    *Users    `gorm:"foreignKey:UserID" json:"user"`
	Likes   []Likes   `gorm:"foreignKey:SpotID" json:"likes"`
	Visited []Visited `gorm:"foreignKey:SpotID" json:"visited"`
}
