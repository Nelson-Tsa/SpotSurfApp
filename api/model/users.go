package model

type Users struct {
	ID       int    `gorm:"primaryKey" json:"id"`
	Name     string `gorm:"not null" json:"name"`
	Email    string `gorm:"not null;unique" json:"email"`
	Password []byte `gorm:"not null" json:"-"`
	Role     string `gorm:"not null" json:"role"`

	// Relations
	Spots   []Spots   `gorm:"foreignKey:UserID" json:"spots,omitempty"`
	Likes   []Likes   `gorm:"foreignKey:UserID" json:"likes,omitempty"`
	Visited []Visited `gorm:"foreignKey:UserID" json:"visited,omitempty"`
}