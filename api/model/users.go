package model

type Users struct {
	ID       int    `gorm:"primaryKey" json:"id"`
	Name     string `gorm:"not null" json:"name"`
	Email    string `gorm:"not null;unique" json:"email"`
	Password string `gorm:"not null" json:"-"`
	Role     string `gorm:"not null" json:"role"`

	Spots   []Spots   `gorm:"foreignKey:UserID" json:"spots"`
	Likes   []Likes   `gorm:"foreignKey:UserID" json:"likes"`
	Visited []Visited `gorm:"foreignKey:UserID" json:"visited"`
}
