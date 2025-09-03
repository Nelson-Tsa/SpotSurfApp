package model

type Spots struct {
	ID          int    `gorm:"primaryKey" json:"id"`
	City        string `gorm:"not null" json:"city"`
	Name        string `gorm:"not null" json:"name"`
	Description string `gorm:"not null" json:"description"`
	Level       string `gorm:"not null" json:"level"`
	Difficulty  string `gorm:"not null" json:"difficulty"`
	Gps         string `gorm:"not null" json:"gps"`
	ImageID     *int   `gorm:"default:null" json:"image_id"` // Nullable avec pointeur
	UserID      int    `gorm:"not null" json:"user_id"`
	LikeCount   int    `gorm:"default:0" json:"like_count"`

	// Relations
	User    *Users    `gorm:"foreignKey:UserID" json:"user,omitempty"`
	Image   *Images   `gorm:"foreignKey:ImageID" json:"image,omitempty"`
	Images  []Images  `gorm:"foreignKey:SpotID" json:"images,omitempty"` // Toutes les images du spot
	Likes   []Likes   `gorm:"foreignKey:SpotID" json:"likes,omitempty"`
	Visited []Visited `gorm:"foreignKey:SpotID" json:"visited,omitempty"`
}
